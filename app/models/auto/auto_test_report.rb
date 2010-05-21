class Auto::AutoTestReport < ActiveRecord::Base
  START_YEAR = 2009
  
  #生成报表
  def self.product_line_bar_testcase_report
    auto_report = Hash.new()
    arr_product_line = Base::ProductLine.find(:all)
    arr_product_line.each { |product_line|
      product_line_testcase_count = product_line.testcase_count
      auto_report[product_line.name + ": #{product_line_testcase_count}"] = product_line_testcase_count
    }
    return auto_report
  end
  
  #  产品线测试用例概况
  def self.product_line_overview 
    arr_auto_overview = Array.new()
    arr_product_line = Base::ProductLine.find(:all)
    arr_product_line.each { |product_line|
      auto_overview = Hash.new()
      auto_overview['product_line_name']=product_line.name
      auto_overview['product_line_id']=product_line.id
      
      #产品线用例总数
      product_line_testcase_count = product_line.testcase_count
      auto_overview['product_line_testcase_count']=product_line_testcase_count
      
      #完成自动化测试用例
      auto_overview['auto_testcase_count']=product_line.auto_testcase_count
      
      #执行过的用例
      arr_testcase = product_line.exec_testcases
      
      passed_count = 0
      failed_count = 0
      activation_count =0 
      arr_testcase.each{|testcase|
         testcase.auto_exec_result=="passed" ? passed_count+=1 : failed_count+=1
         activat_sql="select distinct testcase_id from auto_bgjobs where WEEK(started_at) =WEEK(now()) and testcase_id = #{testcase.id}"
         activation_count +=Auto::AutoBgjob.find_by_sql(activat_sql).size
      }
      #通过数
      auto_overview['passed_count']=passed_count
      #失败数
      auto_overview['failed_count']=failed_count
      #本周活跃度
      auto_overview['activation_count']= activation_count
      
      #通过率
      passed_rate="0.0"
      passed_rate=sprintf("%0.2f", (passed_count.to_f/(passed_count+failed_count))*100)+"%" if passed_count!=0
      auto_overview['passed_rate']=passed_rate
      
      #未执行数
      auto_overview['unexec_testcase_count']=product_line.unexec_testcase_count
      arr_auto_overview<<auto_overview
    }
    auto_overview ={"product_line_name"=>"共计","product_line_id"=>nil,"product_line_testcase_count"=>0,
                    "auto_testcase_count"=>0,"passed_count"=>0,"failed_count"=>0,"activation_count"=>0,"passed_rate"=>0.0,"unexec_testcase_count"=>0}
    arr_auto_overview.each{|auto_overview_hash|
      auto_overview["product_line_testcase_count"]+=auto_overview_hash["product_line_testcase_count"] if auto_overview_hash["product_line_testcase_count"]
      auto_overview["auto_testcase_count"]+=auto_overview_hash["auto_testcase_count"] if auto_overview_hash["auto_testcase_count"]
      auto_overview["passed_count"]+=auto_overview_hash["passed_count"]
      auto_overview["failed_count"]+=auto_overview_hash["failed_count"]
      auto_overview["activation_count"]+=auto_overview_hash["activation_count"] if auto_overview_hash["activation_count"]
      auto_overview["unexec_testcase_count"]+=auto_overview_hash["unexec_testcase_count"] if auto_overview_hash["unexec_testcase_count"]
    }
    passed_rate="0.0"
    passed_rate=sprintf("%0.2f", (auto_overview["passed_count"].to_f/(auto_overview["passed_count"]+auto_overview["failed_count"]))*100)+"%" if auto_overview["passed_count"]!=0
    auto_overview['passed_rate']=passed_rate
    arr_auto_overview<<auto_overview
    return arr_auto_overview
  end
  
  def self.failed_reason_report year,month
      reason_report=Hash.new()
      reason_infos=Setting.reason_infos.select{|e| e}
      reason_infos.each{|reason|
        reason_report_sql = "select ab.id from auto_bgjobs ab,auto_bgjob_suites abs where ab.suite_id=abs.id "
        reason_report_sql += " and abs.bgjob_category_id is not null and ab.reason_info = '#{reason}' "
        reason_report_sql += " and YEAR(ab.done_at)=#{year} and MONTH(ab.done_at) =#{month} "
        size = Auto::AutoBgjob.find_by_sql(reason_report_sql).size
        reason_report[reason+ ": #{size}"] = size
      }
      return reason_report
  end
  
  def self.failed_reason_detail year,month, reason ,page
      reason_report_sql = "select ab.* from auto_bgjobs ab,auto_bgjob_suites abs where ab.suite_id=abs.id "
      reason_report_sql +=" and abs.bgjob_category_id is not null and ab.reason_info = '#{reason}' "
      reason_report_sql +=" and YEAR(ab.done_at)=#{year} and MONTH(ab.done_at) =#{month} order by ab.id desc"
      Auto::AutoBgjob.find_by_sql(reason_report_sql).paginate(:page => page, :per_page => 10)
  end
  
  def self.bug_report year,month,page,product_line,designer
      bug_report_sql =common_sql(year,month,product_line,designer) + " and ab.confirm_result='failed'" + " order by ab.id desc "
      Auto::AutoBgjob.find_by_sql(bug_report_sql).paginate(:page => page, :per_page => 10)
  end
  
  def self.regress_exec_result_report year,month,page,product_line,designer,priority
      regress_exec_result_report_sql = common_sql(year,month,product_line,designer)
      if priority && !priority.empty?
        regress_exec_result_report_sql += " and priority like '#{priority}%'"
      end
      regress_exec_result_report_sql += " order by ab.id desc "
      Auto::AutoBgjob.find_by_sql(regress_exec_result_report_sql).paginate(:page => page, :per_page => 10)
  end
  
  def self.pick_down product_line,pick_down_user,pick_down_at,page
     pick_down_sql = " select pl.name,ts.title as ts_title,tc.title as tc_title,ts.id as ts_id ,tc.id as tc_id,pick_down_at,nickname "
     pick_down_sql += " from testcases_testsuites tts,testcases tc,testsuites ts,projects p,product_lines pl,users "
     pick_down_sql += " where tts.testsuite_id = ts.id and tts.testcase_id = tc.id and users.login = tts.pick_down_user"
     pick_down_sql += " and tc.project_id=p.id and p.line_id=pl.id and pick_down_at is not null"
     if pick_down_user && !pick_down_user.empty?
      pick_down_sql += " and users.login = '#{pick_down_user}' "
     end
     
     if product_line && !product_line.empty?
       pick_down_sql += " and pl.id=#{product_line} "
     end
    
    if pick_down_at && !pick_down_at.empty?
       pick_down_sql += " and date_format(pick_down_at,'%Y-%m-%d')='#{pick_down_at}'"
    end
    pick_down_sql += " order by  ts.id desc"
    Auto::TestcasesTestsuites.find_by_sql(pick_down_sql).paginate(:page => page, :per_page => 20)
  end
  
  
  private
  def self.common_sql year,month,product_line,designer
    common_sql = "select tc.title,tc.priority,users.nickname,pl.name,ab.id,ab.exec_result,ab.reason_info,ab.remark,ab.started_at,ab.done_at "
    common_sql += "from auto_bgjobs ab,auto_bgjob_suites abs,testcases tc ,projects p,product_lines pl,users " 
    common_sql +=" where ab.suite_id=abs.id and ab.testcase_id=tc.id and tc.project_id=p.id and p.line_id=pl.id "
    common_sql += " and abs.bgjob_category_id is not null "
    common_sql += " and YEAR(ab.done_at)=#{year} and MONTH(ab.done_at) =#{month} and users.login like concat(designer,binary '%')"
    if product_line && !product_line.empty?
       common_sql += " and pl.id=#{product_line} "
    end
    if designer && !designer.empty?
       common_sql += " and tc.designer='#{designer}'  "
    end
   return common_sql
  end
  
end
