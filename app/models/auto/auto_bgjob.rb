class Auto::AutoBgjob < ActiveRecord::Base	
  XML_PATH = "#{RAILS_ROOT}/public/auto/staxml"
  EXEC_LOCAL_ROOT ="C:/work/autotest"
  #    named_scope :plan_bgjob_suites, :conditions => {:is_plan => true }, :order => "id ASC"
  belongs_to :testcase, :class_name => "Auto::Testcase"
  belongs_to :suite, :class_name => "Auto::AutoBgjobSuite"
  belongs_to :exec_user, :class_name => "User"
  validates_presence_of :script_path
  #  after_save :failed_redo
  RESULT_STAF_TIMEOUT = "staf_timeout"
  RESULT_STAF_FAILED    = "staf_failed"
  RESULT_SVN_FAILED    = "svn_failed"
  RESULT_RUNNING_TIMEOUT = "running_timeout"
  RESULTS = {RESULT_STAF_TIMEOUT    => "发送STAF超时",
    RESULT_RUNNING_TIMEOUT => "执行超时",
    RESULT_STAF_FAILED     => "发送STAF失败"}
  RESTART = [RESULT_STAF_TIMEOUT,RESULT_STAF_FAILED,RESULT_RUNNING_TIMEOUT,SC_FAILED="sc_failed",TC_FAILED="tc_failed"]
  include Auto::JobModule
  include Auto::JobModule::JobChild
  alias :father :suite
    
  named_scope :state_waiting, :conditions => {:state => STATE_WAITING }, :order => "id ASC"
  
  named_scope :state, lambda { |s|
  	{:conditions => {:state => Array(s) }}
  }
    
    
  before_save do |record|
    if ([STATE_RUNNING, STATE_DONE, STATE_CANCELED].include?(record.state)) && record.started_at.nil?
      assert false , record.inspect
    end
  end
        
  def self.find_all_jobs_to_run
    Machine.auto_avaliables.map{|e|
      self.state_waiting.find_by_exec_ip(e.ip)
    }.compact
  end
		
  def exec_machine
    result = Machine.find_by_ip(self.exec_ip)
    assert result, "machine: #{self.exec_ip} not exist!"
    result
  end
		
  def exec_result_text
    RESULTS[self.exec_result]||self.exec_result
  end
    
  def xml_path(action=nil)
    @xml_path||= begin
      path = File.join(XML_PATH, "#{self.id}.xml")
      if action == :create
        create_xml
      end
      path
    end
  end

  def log_path
    File.join(EXEC_LOCAL_ROOT, "#{self.id}.log")
  end

  def exec_local_path
    EXEC_LOCAL_ROOT + "/" +script_path
  end


  def on_job_done
    super
    Machine.release!(exec_ip,self)
    assert testcase
    assert exec_result
      
    testcase.auto_exec_result = exec_result
    testcase.save
  end

  def on_job_started
    super
    assert self.started_at
    Machine.lock!(exec_ip,self)
  end
    
  def date_format_done_at
    date_format done_at
  end
        
  private
    
  def job_father_fk
    "suite_id"
  end
    
  def date_format(date)
    date.nil? ? "" : date.strftime("%Y-%m-%d %H:%M")
  end

  def create_xml
    FileUtils.mkdir_p XML_PATH
    staxml_content =  Utils.template("#{RAILS_ROOT}/app/views/auto/bgjobs/staff.xml.erb",{:id => self.id,
        :bgjob => "ruby #{exec_local_path.to_unicode.gsub(" ","*")} #{Project.cut_project_id(self.testcase_id)}",
        :staxml_log_path => log_path,
        :rails_root => RAILS_ROOT,
        :rails_env => ENV['RAILS_ENV'] })

    File.open(xml_path, 'w') do |f|
      f << staxml_content
    end
  end
    
  def failed_redo
    if (self.exec_result == "sc_failed" || self.exec_result == "tc_failed") && self.redo_count > 0 && self.state == "done"
      self.exec_result = nil
      self.started_at = nil
      self.done_at = nil
      self.redo_count -= 1
      self.state = "waiting"
      self.save!
    end
  end
end

