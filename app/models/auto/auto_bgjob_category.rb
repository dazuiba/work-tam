class Auto::AutoBgjobCategory < ActiveRecord::Base
  REPORT_SEND="REPORT_SEND"
	include Auto::JobModule
	
	has_many :bgjob_suites, :class_name => "Auto::AutoBgjobSuite", :foreign_key => "bgjob_category_id"
	belongs_to :testsuite_category, :class_name => "Auto::TestsuiteCategory"
	belongs_to :exec_user, :class_name => "User"
 	belongs_to :current_bgjob_suite, :class_name => "Auto::AutoBgjobSuite"
 	
  include Auto::JobModule::JobFather
  alias :children :bgjob_suites     
  alias :children_ids :bgjob_suite_ids
  alias :current_child :current_bgjob_suite
  alias :current_child= :current_bgjob_suite=
	
	#after_create :create_bgjob_suites
	
	def title
		"#{cweek}周#{testsuite_category.title}"
	end
	
	def cweek
		started_at.to_date.cweek
	end
		
	#发送确认通知
	def send_confirm_notify
    
    bgjob_suites_done = bgjob_suites.select{|e|e.state == 'done'}
		bgjob_suites_done.each do |bgjob_suite|
			send_to = bgjob_suite.testsuite.project.users_of_role(Role::AUTO_CHARGE)
			if send_to.size>0
        if bgjob_suite.confirm_state.nil?
				TworkMailer.deliver_bgjob_suite_confirm(bgjob_suite, send_to,self)
				bgjob_suite.confirm_state = Auto::AutoBgjobSuite::CONFIRM_NOTIFIED
				bgjob_suite.save!
        end 
			end
		end
	end
	
  def result
    bgjob_suites_done = bgjob_suites.select{|e|e.state == 'done'}
    bgjob_suites_done.each do |bgjob_suite|
      if bgjob_suite.result_stats.confirm_failed_count>0 then
         return "failed"
      end
    end
     return "passed"
  end
  
  def confirm_state
      bgjob_suites.each do |bgjob_suite|
        if bgjob_suite.confirm_state != Auto::AutoBgjobSuite::CONFIRM_DONE then
           return false
        end
      end
      return true
  end
  
  
	private 
	def create_bgjob_suites		
		self.testsuite_category.testsuites.each do|testsuite|
			bgjob_suite = testsuite.bgjob_suites.build(:exec_ip=>test_suite.plan_ip, :exec_user_id => self.exec_user_id)
			bgjob_suite.save!
		end
	end

end