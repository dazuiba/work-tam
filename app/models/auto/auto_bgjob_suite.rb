class Auto::AutoBgjobSuite < ActiveRecord::Base
  CONFIRM_NOTIFIED = 0
  CONFIRM_START = 1
  CONFIRM_DONE = 2
  CONFIRM_STATES = {
    CONFIRM_NOTIFIED => "邮件已经发送" ,
    CONFIRM_START => "确认中...",
    CONFIRM_DONE  => "已确认"
  }
  class Stats
    attr_reader :jobs, :state_stats, :done_stats
    
    def initialize(suite)
      @jobs = suite.bgjobs
      @state_stats = @jobs.group_by(&:state).build_hash{|state, jobs|[state, jobs]}
      @done_stats = (@state_stats["done"]||[]).group_by(&:exec_result)
    end
    
    def failed
      jobs.count-passed
    end
    
    def passed
      size_of('passed')
    end
    
    def confirm_failed_count
      jobs_falied=jobs.select{|e|e.confirm_result == 'failed'}
      return jobs_falied.size
    end
    
    def confirm_passed_count
      jobs.count-confirm_failed_count
    end
    
    private
    
    def size_of(state)
      if result = done_stats[state]
        result.size
      else
        0
      end
    end
  end
  
  belongs_to :testsuite, :class_name => "Auto::Testsuite"
  belongs_to :exec_user, :class_name => "User"
  belongs_to :current_auto_job, :class_name => "Auto::AutoBgjob"
  belongs_to :bgjob_category, :class_name => "Auto::AutoBgjobCategory"
  has_many :bgjobs, :class_name => "Auto::AutoBgjob", :foreign_key => "suite_id", :dependent=>:delete_all,:order=>"exec_result desc "
  
  before_create :before_create_bgjobs
  after_create :create_bgjobs
  after_save :send_confirm_notify
  
  include Auto::JobModule
  include Auto::JobModule::JobChild
  include Auto::JobModule::JobFather
  
  alias :father :bgjob_category
  alias :children :bgjobs
  alias :children_ids :bgjob_ids
  alias :current_child :current_auto_job
  alias :current_child= :current_auto_job=
  
  def result_stats
    Stats.new(self)
  end
  
  
  def title
    "#{testsuite.title} [#{created_at.to_date.to_s}]"
  end
  
  def confirm_state_text
    confirm_state.nil? ? "邮件未发送" : CONFIRM_STATES[confirm_state]
  end
  
  def all_pick_down?
    if self.testsuite.filter_type=="filter"
      return false
    end
    testcase_suites = Auto::TestcasesTestsuites.find_testsuites self.testsuite.id
    testcase_suites.each do |testcase_suite|
      if testcase_suite.pick_down_at.nil?
        return false
      end
      return true
    end
    
  end
  
  
  private
  
  def job_father_fk
    "bgjob_category_id"
  end
  
  def before_create_bgjobs
    !all_pick_down?
  end
  
  def create_bgjobs
    if self.testsuite.filter_type=="filter"
      testcases = self.testsuite.included_testcases
    else
      testcases = self.testsuite.included_testcases.select{|e|(Auto::TestcasesTestsuites.find_testcases_suites self.testsuite.id,e.id)[0].pick_down_at.nil?}
    end
    testcases.each do|testcase|
      params = self.attributes.slice("exec_user_id", "exec_ip")
      #      params[:script_path] = testcase.script.nil? ? "test.rb" : testcase.script.script_path
      params[:script_path] = testcase.script.nil? ? "" : testcase.script.script_path
      Utils.wangwang(["扬尘"], "test.rb in auto_bgjob_suite.rb", "用例: #{testcase.id}") if testcase.script.nil?
      params[:testcase]    = testcase
      params[:state] = STATE_WAITING
      params[:redo_count] = self.redo_count || 0
      bgjobs.create!(params)
    end
  end

  def send_confirm_notify
    if self.bgjob_category_id && self.state == "done" && self.confirm_state.nil?
      self.bgjob_category.send_confirm_notify
    end
  end
end
