class Auto::BgjobSuitesController < ApplicationController
  include Auto
  #  helper :perf
  before_filter :find_obj, :except => [ :index, :list, :add, :new, :create,:confirm, :bgjob_suite_save]
  
  def index
    @projects = Project.scoped_by_auto(true).scoped_by_line_home(params[:type]!='project')
  end
  
  def show
    @id=params[:id]
    @bgjobs = @bgjob_suite.bgjobs.find(:all,:order=>"exec_result desc").paginate(:page => params[:page], :per_page => 50)
    @exec_result = params[:exec_result]
    if !@exec_result.nil? && !@exec_result.empty?
      if @exec_result == "passed"
        @bgjobs = Auto::AutoBgjob.find(:all,:conditions => [ "suite_id = ? and exec_result = ?",params[:id],@exec_result],:order => " exec_result desc").paginate(:page => params[:page], :per_page => 50)
      elsif @exec_result == "failed"
        @bgjobs = Auto::AutoBgjob.find(:all,:conditions => [ "suite_id = ? and exec_result <> ?",params[:id],"passed"],:order => " exec_result desc").paginate(:page => params[:page], :per_page => 50)
      end
    end
    @arr_header=%w{用例名称 维护者 排队状态 执行结果  开始时间 完成时间 时长(秒) 操作}
    @arr_header = %w{用例名称 维护者 排队状态 执行结果  出错原因 备注 验证时间(分) 验证结果   开始时间 完成时间  时长(秒) 操作} unless @bgjob_suite.confirm_state.nil?||@bgjob_suite.confirm_state==Auto::AutoBgjobSuite::CONFIRM_NOTIFIED
    if @bgjob_suite.bgjob_category && @bgjob_suite.bgjob_category.report_send
      @arr_header = %w{用例名称 维护者 排队状态 执行结果  出错原因 备注 验证时间(分) 验证结果   开始时间 完成时间  时长(秒)}
      @validate_report_data = {"passed:#{@bgjob_suite.result_stats.confirm_passed_count}" => @bgjob_suite.result_stats.confirm_passed_count,"failed:#{@bgjob_suite.result_stats.confirm_failed_count}" =>@bgjob_suite.result_stats.confirm_failed_count}
    end
    @exec_report_data = {"passed:#{@bgjob_suite.result_stats.passed}" => @bgjob_suite.result_stats.passed,"failed:#{@bgjob_suite.result_stats.failed}" =>@bgjob_suite.result_stats.failed}
  end
  def confirm
    @bgjob_suite = AutoBgjobSuite.find(params[:id])
    bgjob_ids=params[:bgjob_ids]
    bgjob_confirm_result = params[:bgjob_confirm_result]
    bgjob_reason_info = params[:bgjob_reason_info]
    bgjob_remark = params[:bgjob_remark]
    bgjob_checkout_times = params[:bgjob_checkout_times]
    if @bgjob_suite.confirm_state == Auto::AutoBgjobSuite::CONFIRM_NOTIFIED
      AutoBgjobSuite.update(@bgjob_suite.id,:confirm_state =>Auto::AutoBgjobSuite::CONFIRM_START)
    elsif @bgjob_suite.confirm_state == Auto::AutoBgjobSuite::CONFIRM_START
      if bgjob_ids
        bgjob_ids.each_with_index{|e,i|
          Auto::AutoBgjob.update(e,{"confirm_result"=>bgjob_confirm_result[i],"reason_info"=>bgjob_reason_info[i],"remark"=>bgjob_remark[i],"checkout_times"=>bgjob_checkout_times[i]})
        }
      end 
      AutoBgjobSuite.update(@bgjob_suite.id,:confirm_state =>Auto::AutoBgjobSuite::CONFIRM_DONE)
      flash["notice"] = "保存成功！"
    elsif @bgjob_suite.confirm_state== Auto::AutoBgjobSuite::CONFIRM_DONE
      if bgjob_ids
        bgjob_ids.each_with_index{|e,i|
          Auto::AutoBgjob.update(e,{"confirm_result"=>bgjob_confirm_result[i],"reason_info"=>bgjob_reason_info[i],"remark"=>bgjob_remark[i],"checkout_times"=>bgjob_checkout_times[i]})
        }
      end 
      flash["notice"] = "保存成功！"
    end
    redirect_to :action => "show",:id=>params[:id]
  end
  
  
  
  def new    
    @bgjob_suite = test_suite.bgjob_suites.build(:created_at=>Time.now)
    render :layout => !request.xhr?
  end
  
  def create
    @bgjob_suite = test_suite.bgjob_suites.build(params[:bgjob_suite])
    @bgjob_suite.exec_user = User.current
    if params[:is_update_script].nil?
      bgjob_suite_save
    else
      exec_machine = Machine.find_by_machine_type_and_ip(1, @bgjob_suite.exec_ip)
      if exec_machine.ping_ok == 1
        result_svn = `STAF #{@bgjob_suite.exec_ip} PROCESS START SHELL COMMAND 'c:/new_setup.bat' FOCUS Minimized RETURNSTDOUT STDERRTOSTDOUT WAIT`
        if Regexp.compile(/(中发现冲突)/).match(result_svn)
          Utils.wangwang(["扬尘"], "脚本执行-SVN冲突", "机器IP: #{@bgjob_suite.exec_ip}")
          flash["error"] = "SVN冲突，请先解决冲突再运行。"
          redirect_to :controller=>"testsuites",:action => "show",:id=>@bgjob_suite.testsuite_id
        else
          bgjob_suite_save
        end
      else
        flash["error"] = "所选机器不可用，请检查STAF是否开启。"
        redirect_to :controller=>"testsuites",:action => "show",:id=>@bgjob_suite.testsuite_id
      end
    end
  end

  def bgjob_suite_save
    begin
      @bgjob_suite.save!
      redirect_to auto_testsuite_url(@bgjob_suite.testsuite, :tab=>"logs")
    rescue
      flash["error"] = "保存失败！"
      redirect_to :controller=>"testsuites",:action => "show",:id=>@bgjob_suite.testsuite_id
    end
  end
  
  def cancel
    @bgjob_suite.destroy
    flash[:notice] = "撤销成功！"
    redirect_to :controller => "auto/testsuites",  :action => "show", :id => @bgjob_suite.testsuite_id
  end
  
  def joblistcancel
    state = @bgjob_suite.children.first.state rescue Auto::JobModule::STATE_WAITING
    unless state == Auto::JobModule::STATE_WAITING
      Machine.kill_ruby_process(@bgjob_suite.exec_ip)
      @bgjob_suite.father.set_state! Auto::JobModule::STATE_CANCELED  if (@bgjob_suite.respond_to? :father) && @bgjob_suite.father
      @bgjob_suite.destroy
      Machine.release!(@bgjob_suite.exec_ip, nil)
      flash[:notice] = "撤销成功！"
    else
      @bgjob_suite.father.set_state! Auto::JobModule::STATE_CANCELED  if (@bgjob_suite.respond_to? :father) && @bgjob_suite.father
      @bgjob_suite.destroy
      flash[:notice] = "撤销成功！"      
    end
    redirect_to :controller => "auto/testsuites/list_by_machine"
  end
  
  def edit
  end
  
  private
  
  def test_suite
    @testsuite ||= Testsuite.find(params[:testsuite_id])
  end
  
  def find_obj
    @bgjob_suite = AutoBgjobSuite.find(params[:id])
  end  
end
