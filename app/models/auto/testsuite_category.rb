class Auto::TestsuiteCategory < ActiveRecord::Base
	has_many :testsuites, :class_name => "Auto::Testsuite",  :foreign_key => "category_id"		
	has_many :bgjob_categories, :class_name => "Auto::AutoBgjobCategory"

  serialize :regress_plan
  serialize :testsuite_regress_ip
  
  def self.create_bgjob_suite (arr_exec, arr_exec_ip,auto_bgjob_categories)
    arr_exec.each{|exec|
      exec_split = exec.split("_")
      index = exec_split[0]
      teststuite_id = exec_split[1]
      exec_ip=arr_exec_ip[index.to_i]
      auto_bgjob_suite=Auto::AutoBgjobSuite.new(:exec_ip => exec_ip,:testsuite_id => teststuite_id,
        :exec_user_id => User.current.id , :state => Auto::JobModule::STATE_WAITING,
        :bgjob_category_id =>auto_bgjob_categories.id )
      auto_bgjob_suite.save
    }
  end
  
  def self.get_category_id category_str
    return category_str.split("_")[1].to_i
  end

  def self.find_all_regress_plan
		find(:all, :conditions => "regress_plan is not null").select{|e|e.exec_plan_now?}
	end

	def exec_plan_now?
		return false if self.regress_plan.blank?
		exec_hour =self.regress_plan['start_time']

		exec_now = if(wdays = self.regress_plan['wday'])
			#按周
			wdays.include?(Date.today.wday.to_s) && exec_hour.to_s == Time.now.hour.to_s
		else
			#按天
			exec_hour == Time.now.hour.to_s
		end
		exec_now
	end

  def user_name
    if self.exec_user_id
      User.find(self.exec_user_id).name
    else
      ""
    end
  end
  
	def last_job_done_or_canceled?
    return true unless bgjob_categories.last
    [Auto::JobModule::STATE_CANCELED, Auto::JobModule::STATE_DONE].include? bgjob_categories.last.state
	end
  
end