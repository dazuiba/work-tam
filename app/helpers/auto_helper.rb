module AutoHelper        
  
  def textilizable(text)
    auto_link(CGI::escapeHTML(text))
  end
  
  def link_to_redmine(name, path, html_options={})    
    path.sub!(/^\//, "")
    link_to name, "http://twork.taobao.net/redmine/#{path}", html_options.reverse_merge(:popup=>true)
  end                        
  
  def result_stat_header
		"Failed/Passed"
  end

  def link_to_testsuite_result_stat(bgjob_suite) 
    stat = bgjob_suite.result_stats
    link_to "#{stat.failed}/#{stat.passed}", 
      {:controller =>"/auto/bgjob_suites",
      :action => "show",
      :id =>bgjob_suite.id}, :popup=>true
    
  end
  
  def select_machine_tag(name, selected=nil, options={})
    #options.reverse_merge!(:local => false)
    machines = Machine.auto.publics
    if options[:local]
      machines.unshift(Machine.find_or_create_private(User.current, request.remote_ip))
    end 				
    select_tag(name, options_for_select(machines.map{|e|["#{e.name}(#{e.ip})", e.ip]}, selected))
  end
  
  def select_product_tag(name, selected=nil, options={})
    products = Base::ProductLine.find(:all)
    products_options = products.map{|e|[e.name, e.id]}.unshift ["请选择产品线", nil]
    select_tag(name, options_for_select(products_options, selected))
  end
  
  def select_designer_tag(name, selected=nil, options={})
    designers = Auto::Testcase.designer
    designers_options = designers.map{|e|["#{e.attributes["designer"]}#{e.attributes["nickname"]}",e.attributes["designer"]]}.unshift ["请选择负责人", nil]
    select_tag(name, options_for_select(designers_options, selected))
  end
  
  def select_pick_down_user (name, selected=nil, options={})
    pick_down_user = User.find(:all)
    pick_down_user_options = pick_down_user.map{|e|["#{e.login}#{e.nickname}",e.login]}.unshift ["请选择下架人", nil]
    select_tag(name, options_for_select(pick_down_user_options, selected))
  end
  
  def select_priority_tag (name, selected=nil, options={})
    priorities = Auto::Testcase.priority
    select_tag(name, options_for_select(priorities.map{|priority|[priority.priority, priority.priority]}, selected))
  end
  
  
  def bgjob_suite_result(jobsuite)
  	""
  end
  
  def bgjob_result(bgjob,options={})
    if bgjob.nil? || bgjob.exec_result.blank?
      if bgjob.nil?
        return "空" 
      else
        if bgjob.state == "done"
          if options[:truncate]
            return truncate("请校验是否存在ruby进程挂掉的现象", options[:truncate])
          else
            return "请校验是否存在ruby进程挂掉的现象"
          end
        else
          return "空"
        end
      end
    else
      link = ""
      if !options[:link_disable]
        link = link_to_popup "查看日志",log_auto_bgjob_url(bgjob.id)
      end
      color ="<font color='red'>#{bgjob.exec_result}</font>"
      color ="<font color='green'>#{bgjob.exec_result}</font>" if bgjob.exec_result == "passed"
			%[<span class="status">#{color}#{" "}</span>#{link}]
    end		
  end
  
  def redo_count(bgjob)
    if  bgjob.father.redo_count && bgjob.redo_count
      (bgjob.father.redo_count - bgjob.redo_count).to_s + "/" + bgjob.father.redo_count.to_s
    else
      0
    end
  end
  
  def bgjob_state(bgjob)
    return nil if bgjob.state.nil?
    Auto::AutoBgjob::STATES[bgjob.state.to_sym]			
  end
  
  def testsuite_info(testsuite)		
    result = if testsuite.project.line_home?
      %[产品线：<strong>#{@testsuite.project.product_line.name}</strong>&nbsp;]
    else
	  	%[项目：<strong>  #{@testsuite.project.name} </strong>]		
    end
    result
  end
  
  def select_char_options(week,day)
    @testsuite.exec_plan['wday'].nil? ? day : week unless @testsuite
  end
  
  def select_int_options
    if  @testsuite && @testsuite.exec_plan && !@testsuite.exec_plan["start_time"].empty?
      @testsuite.exec_plan["start_time"].to_i
    else        
    end
  end
  
  def select_start_time testsuite_category
    if  testsuite_category && testsuite_category.regress_plan && !testsuite_category.regress_plan["start_time"].empty?
      testsuite_category.regress_plan["start_time"].to_i
    else        
    end
  end
  
  
  def select_wday(testsuite_category,i)
    testsuite_category && testsuite_category.regress_plan && testsuite_category.regress_plan['wday'] && testsuite_category.regress_plan['wday'].map(&:to_i).include?(i) ? true : false
  end
  
  def check_box_options(i)
    @testsuite && @testsuite.exec_plan && @testsuite.exec_plan['wday'] && @testsuite.exec_plan['wday'].map(&:to_i).include?(i) ? true : false
  end
  
  def wday_exsist
    @testsuite && @testsuite.exec_plan && @testsuite.exec_plan['wday']
  end
  
  def default_wday
    if @testsuite &&  @testsuite.exec_plan && @testsuite.exec_plan['wday']
      @testsuite.exec_plan['wday'].map(&:to_i).inspect
    end
  end
  
  def plan_date(wday)    
    date = ""
    date << "周一 " if  wday && wday.inspect.include?("1")
    date << "周二 " if  wday && wday.inspect.include?("2")
    date << "周三 " if  wday && wday.inspect.include?("3")
    date << "周四 " if  wday && wday.inspect.include?("4")
    date << "周五 " if  wday && wday.inspect.include?("5")
    date << "周六 " if  wday && wday.inspect.include?("6")
    date << "周日 " if  wday && wday.inspect.include?("0")
    date.empty? ? "按日" : date
  end
  
  def plan_time(testplan)
    stime = testplan.exec_plan["start_time"]
    stime + "点"
  end
  
  def link_to_edit_plan(testplan)
    link_to_popup l(:button_edit),
      editplan_auto_testsuite_url(testplan.id),
      :class => 'icon icon-edit'
    
  end
  
  def link_to_cancel(obj)
    link_to "删除" ,cancel_auto_testsuites_url(:id => obj.id),
      :class => 'icon icon-cancel'
  end
  
  def date_format(date)
    date.nil? ? "" : date.strftime("%Y-%m-%d %H:%M") 
  end
  
  def duration_format(duration)
    duration.nil? ? 0 : duration
  end
  
  def auto_state_str (script_id)
    auto_state_string = ""
    script_id.nil? ? auto_state_string = "未完成" : auto_state_string = "已完成"
    return auto_state_string
  end
  
  def auto_state_selected(auto_state,target)
    return "selected=true" if auto_state==target
    return ""
  end
  #测试任务列表
  def ip_for_select(options = {})
    machines = Machine.auto.publics
    if options[:local]
      machines.unshift(Machine.find_or_create_private(User.current, request.remote_ip))
    end
    machines.map{|e|["#{e.name}(#{e.ip})", e.ip]}
  end
  
  def state_options
    Auto::JobModule::STATES.collect{|k,v|[v,k]}
  end
  
  def testsuite_tilte(suite_bgjob)
    suite_bgjob.testsuite.nil? ? "" : suite_bgjob.testsuite.title
  end
  
  def exec_user(user_id)
    if user_id.nil?
      ""
    else
      User.find(user_id).nickname
    end
  end
  
  def case_name(bgjob)
    bgjob.testcase.nil? ? "" : bgjob.testcase.title
  end
  
  def state_format(state)
    Auto::JobModule::STATES[state]
  end
  
  def make_plan_ip testsuite_categories ,testsuite
    plan_ip = ""
    if testsuite_categories.testsuite_regress_ip
      testsuite_categories.testsuite_regress_ip["arr_exec"].each{|exec|
        exec_split = exec.split("_")
        index = exec_split[0].to_i
        teststuite_id = exec_split[1]
        if teststuite_id == testsuite.id.to_s
          plan_ip =testsuite_categories.testsuite_regress_ip["arr_exec_ip"][index]
          break
        end
      }
    end
    plan_ip = testsuite.plan_ip if plan_ip == ""
    return plan_ip
  end
  def confirm_state auto_bgjob_suites
    if auto_bgjob_suites.confirm_state == Auto::AutoBgjobSuite::CONFIRM_NOTIFIED
      return submit_tag "开始确认"
    elsif auto_bgjob_suites.confirm_state==Auto::AutoBgjobSuite::CONFIRM_START
      return submit_tag  "确认"
    elsif auto_bgjob_suites.confirm_state==Auto::AutoBgjobSuite::CONFIRM_DONE
      return submit_tag "保存"
    else
      return ""
    end
  end
  
  def need_restart?(bgjob)
    return false unless bgjob
    (Auto::AutoBgjob::RESTART.include?bgjob.exec_result) && (bgjob.state != Auto::JobModule::STATE_RUNNING)
  end
  
  def testcase_pick_down? testsuite_id,testcase_id
    suites_case = Auto::TestcasesTestsuites.find(:first,:conditions=>{"testsuite_id"=>testsuite_id,"testcase_id"=>testcase_id})
    suites_case && suites_case.pick_down_at ? true:false
  end
  
  def result rs
    color ="<font color='red'>#{rs}</font>"
    color ="<font color='green'>#{rs}</font>" if rs == "passed"
    return color
  end

  def init_tree(parent_id)
    str = "["
    tcs_level1 = Auto::TestcaseCategory.find_all_by_parent_id(parent_id, :select => "id, parent_id, position, title")
    for i in 0..tcs_level1.size-1 do
      tc1 = tcs_level1[i]
      if (tc1.old_children.size > 0)
        str += "{ attributes : { \"id\" : \"#{tc1.id}\", href : \"/auto/testcase_categories/#{tc1.id}/testcase_list\" }, data : #{tc1.text.to_json}, state : \"open\", "
        str += "children : ["
        tcs_level2 = Auto::TestcaseCategory.find_all_by_parent_id(tc1.id, :select => "id, parent_id, position, title")
        for j in 0..tcs_level2.size-1 do
          tc2 = tcs_level2[j]
          str += "{ attributes : { \"id\" : \"#{tc2.id}\", href : \"/auto/testcase_categories/#{tc2.id}/testcase_list\" }, data : #{tc2.qc_title.to_json}, state : \"closed\" }"
          if j < tcs_level2.size-1
            str += ","
          end
        end
        str += "]"
        str += "}"
      else
        str += "{ attributes : { \"id\" : \"#{tc1.id}\", href : \"/auto/testcase_categories/#{tc1.id}/testcase_list\" }, data : #{tc1.text.to_json}, state : \"open\" }"
      end
      if i < tcs_level1.size-1
        str += ","
      end
    end
    str += "]"
  end

end
