#require File.dirname(__FILE__)+"/../../../lib/twork/ext/string"
class Auto::BgjobsController < ApplicationController
  before_filter :find_obj, :except => [ :index, :list, :add, :new, :create, :load_log,:list_by_machine,:get_sub_items,:create_job,:bgjob_save, :job_done_staf, :get_job]
  before_filter :create_obj,:only => [:create,:create_job]
  
  #  act_as_extjs_direct
  include Auto
  include Search
  include CommonUtils
  
  EXEC_RESULT = {0=> 'passed', 1=>"sc_failed", 2=>"tc_failed"}

  def new
    @bgjob=AutoBgjob.new();
    respond_to do |format|
      format.html {render :layout=>false}
      format.xml  { render :xml => @bgjob }
    end
  end
  
  def create
    if @bgjob.save
      render_direct :text => "{success:true}"
    else
      render_direct :text => "{success:false}"
    end
  end
  
  def create_job
    if request.get?
      @testcase = Auto::Testcase.find(params[:id])
      @target = params[:target]
    else
      if params[:is_update_script].nil?
        bgjob_save
      else
        exec_machine = Machine.find_by_machine_type_and_ip(1, @bgjob.exec_ip)
        if exec_machine.ping_ok == 1
          result_svn = `STAF #{@bgjob.exec_ip} PROCESS START SHELL COMMAND 'c:/new_setup.bat' FOCUS Minimized RETURNSTDOUT STDERRTOSTDOUT WAIT`
          if Regexp.compile(/(中发现冲突)/).match(result_svn)
            Utils.wangwang(["扬尘"], "脚本执行-SVN冲突", "机器IP: #{@bgjob.exec_ip}")
            render :text => "<span style=\"color: red;\">SVN冲突，请先解决冲突再运行。</span><br><a href=\"javascript:history.back()\">返回</a>"
          else
            bgjob_save
          end
        else
          render :text => "<span style=\"color: red;\">所选机器不可用，请检查STAF是否开启。</span><br><a href=\"javascript:history.back()\">返回</a>"
        end
      end
    end
  end

  def bgjob_save
    if @bgjob.save
      if params[:target].blank?
        redirect_to(:controller=>"testsuites",:action=>"list_by_machine",:tab=>"testcases")
      else
        redirect_to "/auto/testcases/#{params[:testcase_id]}/show_testcase?tab=script" if params[:target]=="show_testcase"
        redirect_to "/auto/testcases/#{params[:testcase_id]}/show_testcase?tab=script" if params[:target]=="testcase_list"
        redirect_to "/auto/testcases/#{params[:testcase_id]}/show_testcase?tab=script" if params[:target]=="testcase_search"
      end
    else
      render :text => "创建失败！<a href=\"javascript:history.back()\">返回</a>"
    end
  end
  
  #stax执行完任务后，回调使用
  # @see RAILS_ROOT/script/auto_stax_callback
  def job_done
    #assert request.post?
    @bgjob.attributes = params.slice(:exec_result,:result_log)
    if ( params[:exec_result] == "sc_failed" || params[:exec_result] == "tc_failed") && @bgjob.redo_count.to_i > 0
      @bgjob.redo_count -= 1
      Machine.release!(@bgjob.exec_ip,@bgjob)
      @bgjob.set_state! "waiting"
    else
      @bgjob.set_state! "done"
    end
    
    render :text=>"ok"
  end

  def job_done_staf
    assert request.post?
    log "Start Callback... #{params[:starttime]} #{params[:endtime]}"
    @bgjob = AutoBgjob.find(params[:bgjob_id].to_i)
    result_log = params[:output].to_s
    log result_log
    @bgjob.result_log = result_log||"".to_utf8
    exec_result = EXEC_RESULT[params[:exitcode].to_i]
    @bgjob.exec_result = exec_result
    if ( exec_result == "sc_failed" || exec_result == "tc_failed") && @bgjob.redo_count > 0
      @bgjob.redo_count -= 1
      Machine.release!(@bgjob.exec_ip,@bgjob)
      @bgjob.set_state! "waiting"
    else
      @bgjob.set_state! "done"
    end
    log "Callback For #{params[:bgjob_id]}, Result: #{exec_result}"
    render :text=>"ok"
  end

  def get_job
    render :text => "a;b;c"
  end
  
  def log
    render :layout=>false
  end
  
  def load_log
    testcase_id = params[:testcase_id]
    @auto_bgjob = Auto::AutoBgjob.find(:first,:conditions => [" #{Auto::JobModule::DONE} and testcase_id=?",testcase_id],:order => "id desc")
    obj=Hash.new
    obj={:done_at => nil,:exec_result => nil,:result_log =>nil,:reason_info =>nil}
    obj = @auto_bgjob.as_json() if @auto_bgjob
    if @auto_bgjob && @auto_bgjob.exec_user
      obj[:nickname] = @auto_bgjob.exec_user.nickname
    else
      obj[:nickname] = ""
    end
    render_direct obj
  end
  
  ##
  #For Extjs
  ##
  def result_log    
    jobId = params[:id]
    @auto_bgjob = Auto::AutoBgjob.find(jobId)
    obj=Hash.new
    obj[:result_log] = @auto_bgjob.result_log
    obj[:reason_info] = @auto_bgjob.reason_info
    render_direct obj
  end  
  
  
  def update
    if params[:reason_info]
      Auto::AutoBgjob.update(params[:id],{"reason_info"=>params[:reason_info]})
    end
    @auto_bgjob = Auto::AutoBgjob.find(params[:id])
    obj = @auto_bgjob.as_json()
    if !@auto_bgjob.exec_user.nil?
      obj[:nickname] = @auto_bgjob.exec_user.nickname
    else
      obj[:nickname] = ""
    end
    render_direct obj
  end
  
  def list
    exec_result = params[:exec_result]
    started_at = params[:started_at]
    done_at = params[:done_at]
    testcase_id = params[:testcase_id]
    testcase = Testcase.find(testcase_id)
    conditions = testcase_log_search(testcase_id,exec_result,started_at,done_at)
    bgjobs = Auto::AutoBgjob.find(:all,:conditions => conditions,:order => "id desc")
    objs = Array.new(bgjobs.size)
    bgjobs.each_index{|index|
      bgjob = bgjobs[index]
      obj = bgjob.as_json()
      obj[:nickname] = bgjob.exec_user.nickname if bgjob.exec_user
      obj[:title] = testcase.title
      objs[index] = obj
    }
    render_direct objs
  end
  
  def restart
    script_path = @bgjob.testcase.script.script_path rescue @bgjob.script_path
    @bgjob.attributes ={:script_path => script_path, :started_at => Time.now,:done_at => nil,:exec_result => nil}
    @bgjob.set_state! Auto::JobModule::STATE_WAITING
    redirect_to :back
  end
  
  def cancel
    redirect_to :back
    if @bgjob.state == "running"
      Machine.kill_ruby_process(@bgjob.exec_ip)
      @bgjob.destroy
      Machine.release!(@bgjob.exec_ip, nil)
      flash[:notice] = "撤销成功！"
    else
      @bgjob.destroy
      flash[:notice] = "撤销成功！"
    end
  end
  
  private
  
  def find_obj
    @bgjob = AutoBgjob.find(params[:id])
  end
  
  def create_obj
    if !request.get?
      script = Auto::Testcase.find(params[:testcase_id]).script
      #      script_path = script.nil? ? "test.rb" : script.script_path
      script_path = script.nil? ? "" : script.script_path
      Utils.wangwang(["扬尘"], "test.rb in bgjobs_controller.rb", "用例: #{params[:testcase_id]}") if script.nil?
      exec_ip = handle params[:exec_ip],request.remote_ip
      @bgjob = AutoBgjob.new(:testcase_id=>params[:testcase_id],
        :exec_ip=>exec_ip,
        :script_path=> script_path,
        :state => Auto::JobModule::STATE_WAITING,
        :exec_user => User.current);
    end
  end
  
	def log(msg)
		File.open("log/callback.log","a"){|e|e.puts "#{Time.now.strftime('%Y/%m/%d %H:%M:%S')}: #{msg}" }
	end
end
