module Search
  def testcase_log_search(testcase_id,exec_result,started_at,done_at)
    conditions = "testcase_id=#{testcase_id} and #{Auto::JobModule::DONE} "
    unless exec_result.blank?
      conditions1 = ["exec_result like ? ","#{exec_result}"]
      conditions = Auto::AutoBgjob.merge_conditions(conditions,conditions1)
    end
    
    unless started_at.blank?
      conditions1 = ["date_format(started_at,'%Y-%m-%d') >= ? ","#{started_at}"]
      conditions = Auto::AutoBgjob.merge_conditions(conditions,conditions1)
    end
    unless done_at.blank?
      conditions1 = ["date_format(done_at,'%Y-%m-%d') <= ? ","#{done_at}"]
      conditions = Auto::AutoBgjob.merge_conditions(conditions,conditions1)
    end
    puts conditions.inspect
    return conditions
  end
  
  def test_plan_search(title = nil,exec_user_name = nil)
    conditions = "1=1"
    unless title.blank?
      title = title.gsub(' ',"%")
      conditions1 = ["title like ? ","%#{title}%"]
      conditions = Auto::Testsuite.merge_conditions(conditions,conditions1)
    end

    unless exec_user_name.blank?
      user_ids = "0"
      User.find_id_by_login_or_nickname(exec_user_name,exec_user_name).each do |f|
        user_ids << ",#{f.id}"
      end
      conditions1 = ["created_by_id in (#{user_ids}) "]
      conditions = Auto::Testsuite.merge_conditions(conditions,conditions1)
    end
     
    return conditions

  end

  #  def search_bgjob_list(exec_ip,suite_title,exec_user_name,state,start_time,end_time)
  def search_bgjob_list(params)
    exec_ip        = params["ip"]
    suite_title    = params["name"]
    exec_user_name = params["user_name"]
    state          = params["state"]
    start_time     = params["start_time"]
    end_time       = params["end_time"]

    conditions = "1=1"
    unless exec_ip.blank?
      conditions1 = ["exec_ip = ? ",exec_ip]
      conditions = Auto::AutoBgjobSuite.merge_conditions(conditions,conditions1)
    end

    unless suite_title.blank?
      suite_title = suite_title.gsub(' ',"%")
      testsuite_ids = "0"
      Auto::Testsuite.ts_title_like("#{suite_title}").map(&:id).each do |id|
        testsuite_ids <<  ",#{id}"
      end
      conditions1 = ["testsuite_id in (#{testsuite_ids})"]
      conditions = Auto::AutoBgjobSuite.merge_conditions(conditions,conditions1)
    end

    unless exec_user_name.blank?
      exec_user_name = exec_user_name.gsub(" ","%")
      user_ids = "0"
      User.find_id_by_login_or_nickname(exec_user_name,exec_user_name).each do |f|
        user_ids << ",#{f.id}"
      end
      conditions1 = ["exec_user_id in (#{user_ids}) "]
      conditions = Auto::AutoBgjobSuite.merge_conditions(conditions,conditions1)
    end

    unless state.blank?
      conditions1 = ["state = ? ",state]
      conditions = Auto::AutoBgjobSuite.merge_conditions(conditions,conditions1)
    end

    unless start_time.blank?
      conditions1 = ["date_format(started_at,'%Y-%m-%d') >= ? ","#{start_time}"]
      conditions = Auto::AutoBgjobSuite.merge_conditions(conditions,conditions1)
    end

    unless end_time.blank?
      conditions1 = ["date_format(done_at,'%Y-%m-%d') <= ? ","#{end_time}"]
      conditions = Auto::AutoBgjobSuite.merge_conditions(conditions,conditions1)
    end
    return conditions
  end


  def search_case_list(params)
    exec_ip        = params["ip"]
    case_title    = params["name"]
    exec_user_name = params["user_name"]
    state          = params["state"]
    start_time     = params["start_time"]
    end_time       = params["end_time"]

    conditions = "suite_id = 0"
    unless exec_ip.blank?
      conditions1 = ["exec_ip = ? ",exec_ip]
      conditions = Auto::AutoBgjob.merge_conditions(conditions,conditions1)
    end

    unless case_title.blank?
      case_title = case_title.gsub(' ',"%")
      testcase_ids = "0"
      Auto::Testcase.case_title_like("#{case_title}").map(&:id).each do |id|
        testcase_ids <<  ",#{id}"
      end
      conditions1 = ["testcase_id in (#{testcase_ids})"]
      conditions = Auto::AutoBgjob.merge_conditions(conditions,conditions1)
    end

    unless exec_user_name.blank?
      exec_user_name = exec_user_name.gsub(" ","%")
      user_ids = "0"
      User.find_id_by_login_or_nickname(exec_user_name,exec_user_name).each do |f|
        user_ids << ",#{f.id}"
      end
      conditions1 = ["exec_user_id in (#{user_ids}) "]
      conditions = Auto::AutoBgjob.merge_conditions(conditions,conditions1)
    end

    unless state.blank?
      conditions1 = ["state = ? ",state]
      conditions = Auto::AutoBgjob.merge_conditions(conditions,conditions1)
    end

    unless start_time.blank?
      conditions1 = ["date_format(started_at,'%Y-%m-%d') >= ? ","#{start_time}"]
      conditions = Auto::AutoBgjob.merge_conditions(conditions,conditions1)
    end

    unless end_time.blank?
      conditions1 = ["date_format(done_at,'%Y-%m-%d') <= ? ","#{end_time}"]
      conditions = Auto::AutoBgjob.merge_conditions(conditions,conditions1)
    end
    
    return conditions
  end
  
  
  def regress_search (started_at)
    conditions = " started_at is not null  "
    unless started_at.blank?
      conditions1 = ["date_format(started_at,'%Y-%m-%d') = ? ","#{started_at}"]
      conditions = Auto::AutoBgjobCategory.merge_conditions(conditions,conditions1)
    end
    return conditions
  end
  
end
