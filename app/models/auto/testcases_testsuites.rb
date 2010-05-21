class Auto::TestcasesTestsuites < ActiveRecord::Base
  belongs_to :testsuite
  belongs_to :testcase
  
  def self.pick_down_bat pick_down_suites_and_case,testsuite_id
    
    testcases_suites = Auto::TestcasesTestsuites.find(:all,:conditions =>["testsuite_id = #{testsuite_id} and pick_down_at is not null"])
    
    testcases_suites.each{|cases_suites|
      pick_up cases_suites.testsuite_id,cases_suites.testcase_id
    }
    
    pick_down_suites_and_case.each{|suites_and_case|
      arr_suites_and_case = suites_and_case.split('_')
      pick_down arr_suites_and_case[0],arr_suites_and_case[1]
    }
    
  end
  
  def self.pick_up_bat pick_up_suites_and_case
    pick_up_suites_and_case.each{|suites_and_case|
      arr_suites_and_case = suites_and_case.split('_')
      pick_up arr_suites_and_case[0],arr_suites_and_case[1]
    }
  end
  
  
  def self.pick_down testsuite_id,testcase_id
    Auto::TestcasesTestsuites.update_all("pick_down_at = '#{Time.now.strftime("%Y-%m-%d %H:%M")}',pick_down_user = '#{User.current}'",
                                           "testsuite_id = #{testsuite_id} and testcase_id = #{testcase_id}")
  end 
  
  def self.pick_up testsuite_id,testcase_id
    Auto::TestcasesTestsuites.update_all("pick_down_at = null,pick_down_user = '#{User.current}'",
                                           "testsuite_id = #{testsuite_id} and testcase_id =#{testcase_id}")
  end
  
  def self.find_testcases_suites testsuite_id,testcase_id
    Auto::TestcasesTestsuites.find(:all,:conditions =>["testsuite_id = #{testsuite_id} and testcase_id =#{testcase_id}"])
  end
  
  def self.find_testsuites testsuite_id
    Auto::TestcasesTestsuites.find(:all,:conditions =>["testsuite_id = #{testsuite_id}"])
  end
  end
