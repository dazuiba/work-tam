class Admin::TestsuitesCategoriesController < Admin::ApplicationController
  
  include Auto
  include Search
  before_filter :find_obj, :only=>[:send_report, :report]
  
  def send_report
  	if request.get?
  		@mail_to = @job_category.testsuite_category.mail_to
  		render :layout => !request.xhr?
		else
      if @job_category.confirm_state   
        TworkMailer.deliver_category_report(@job_category, params[:mail_to].split(";"))
        Auto::AutoBgjobCategory.update(@job_category.id,:report_send=>Auto::AutoBgjobCategory::REPORT_SEND)
        flash[:notice] = "发送成功"
      else
        flash[:notice] = "还有产品线没有确认" 
      end
  		redirect_to request.referer
		end  	
  end
  
  def index
    @category = Auto::TestsuiteCategory.all
    @cate_tabs =  Auto::TestsuiteCategory.all.map{|category|
      {(Auto::JobModule::CATEGORY+category.id.to_s).to_sym => category.title}      
    }
    puts @cate_tabs.inspect
    
    @testsuites =Auto::Testsuite.find(:all,:conditions => ["category_id is not null"])
  end
  
  def new
    @category_id =Auto::TestsuiteCategory.get_category_id params[:category_id]
    @testsuites =Auto::Testsuite.find(:all,:conditions => ["category_id=?",@category_id])
    render :layout=>!request.xhr?
  end
  
  def create
    @category_id =Auto::TestsuiteCategory.get_category_id params[:category_id]
    arr_exec = params[:exec]
    arr_exec_ip = params[:exec_ip]
    auto_bgjob_categories = Auto::AutoBgjobCategory.new(:exec_user_id => User.current.id,
      :state => Auto::JobModule::STATE_WAITING,
      :testsuite_category_id=>@category_id)
    uniq_arr_exec_ip = []
    arr_exec.each {|exec|
      exec_split = exec.split("_")
      index = exec_split[0]
      uniq_arr_exec_ip << arr_exec_ip[index.to_i]
    }
    uniq_arr_exec_ip = uniq_arr_exec_ip.uniq
    result = machines_states(uniq_arr_exec_ip)
    if result == "<span style=\"color: red;\"></span>"
      if auto_bgjob_categories.save
        Auto::TestsuiteCategory.create_bgjob_suite(arr_exec,arr_exec_ip,auto_bgjob_categories)
        Auto::Testsuite.update_all( "checked = null", "category_id = #{@category_id}" )
        redirect_to :action => "list" ,:category_id=>params[:category_id]
      else
        render :text => "任务创建失败！"
      end
    else
      render :text => result+"<a href=\"javascript:history.back()\">返回</a>"
    end
  end
  
  def make_plan
    @category_id =Auto::TestsuiteCategory.get_category_id params[:category_id]
    @testsuites =Auto::Testsuite.find(:all,:conditions => ["category_id=?",@category_id])
    @testsuite_category = Auto::TestsuiteCategory.find(@category_id)
    render :layout=>!request.xhr?
    
  end
  def create_make_plan
    testsuite_regress_ip = HashWithIndifferentAccess.new
    testsuite_regress_ip[:arr_exec] = params[:exec]
    testsuite_regress_ip[:arr_exec_ip] = params[:exec_ip]
    category_id = Auto::TestsuiteCategory.get_category_id params[:category_id]
    regress_plan = params[:regress_plan]
    mail_to = params[:mail_to]
     
    if Auto::TestsuiteCategory.update(category_id,:regress_plan => regress_plan,
        :testsuite_regress_ip => testsuite_regress_ip,
        :exec_user_id => User.current.id,
        :mail_to => mail_to)
      @current = Auto::TestsuiteCategory.find category_id
      flash[:notice] = "#{@current.user_name} 定制了回归计划，于周#{@current.regress_plan["wday"]} --#{@current.regress_plan["start_time"]}点"
      redirect_to :back
    end
      
  end
  
  def list
    @active_tab = params[:category_id]
    @category_id = Auto::TestsuiteCategory.get_category_id @active_tab
    @testsuite_category=Auto::TestsuiteCategory.find(@category_id)
    @started_at = params[:started_at]
    conditions = regress_search @started_at
    @auto_bgjob_categories = Auto::AutoBgjobCategory.find(:all,:conditions => conditions,:order => "id desc").paginate(:page => params[:page], :per_page => 20)
    @list_cate_tabs =  Auto::TestsuiteCategory.all.map{|category|
      {(Auto::JobModule::CATEGORY+category.id.to_s).to_sym => "#{category.title}历史记录"}      
    }
  end
  
  def report
  	if params[:go] == "notify"
    	#发送确认通知
    	@job_category.send_confirm_notify
      flash[:notice] = "发送成功"	
    	redirect_to request.referer	
    else    	
  		@auto_bgjob_suites = @job_category.bgjob_suites
  	end

  end

  def save
    begin
      all = params[:all]
      selected = params[:selected]
      arr_all = all.split(" ")
      arr_selected = selected.split(" ")
      arr_unselected = arr_all - arr_selected
      if arr_selected.size > 0
        arr_selected.each { |sel| 
          Auto::Testsuite.update(sel.gsub("exec_", "").to_i, {:checked => 1})
        }
      end
      arr_unselected.each { |unselected| 
        Auto::Testsuite.update(unselected.gsub("exec_", "").to_i, {:checked => nil})
      }
      render :text => "保存成功！"
    rescue
      render :text => "保存失败！"
    end
  end

  private
  
  def find_obj
  	@job_category = Auto::AutoBgjobCategory.find(params[:id])  	
  end

  def machines_states(machines)
    str_results = ""
    machines.each {|exec_ip|
      exec_machine = Machine.find_by_machine_type_and_ip(1, exec_ip)
      if exec_machine.ping_ok == 1
        result_svn = `STAF #{exec_ip} PROCESS START SHELL COMMAND 'c:/new_setup.bat' FOCUS Minimized RETURNSTDOUT STDERRTOSTDOUT WAIT`
        if Regexp.compile(/(中发现冲突)/).match(result_svn)
          Utils.wangwang(["扬尘"], "脚本执行-SVN冲突", "机器IP: #{exec_ip}")
          str_results += "#{exec_ip}：SVN冲突，请先解决冲突再运行。<br>"
        else
        end
      else
        str_results += "#{exec_ip}：所选机器不可用，请检查STAF是否开启。<br>"
      end
    }
    return "<span style=\"color: red;\">"+str_results+"</span>"
  end

  def clear_sessions
    
  end
end