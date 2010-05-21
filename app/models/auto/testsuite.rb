class Auto::Testsuite < ActiveRecord::Base
  TYPE_SELECT = "select"
  TYPE_FILTER = "filter"
	has_and_belongs_to_many :testcases, :class_name => "Auto::Testcase"
	belongs_to :project,	:foreign_key => "range_id"
	belongs_to :created_by, :class_name => "User"
	has_many :bgjob_suites, :class_name =>  "Auto::AutoBgjobSuite", :dependent=>:delete_all  
  named_scope :is_testplan , :conditions => "exec_plan is not null"
  named_scope :ts_title_like, lambda{|title|{:conditions => ["title like ?","%#{title}%"]}}


	serialize :query_condition
	serialize :exec_plan
		
	validates_presence_of :title
  validates_presence_of :plan_ip, :if => Proc.new { |suite| suite.exec_plan } 
  #  validates_presence_of :category_id
	validates_uniqueness_of :title, :scope=>[:range_id]
  #	validates_uniqueness_of :category_id, :scope => [:range_id], :message => "每个基线只能有一个回归测试集",
  #    :if => Proc.new { |suite| suite.category_id }
	attr_accessor :query
	
	before_validation do|record|
    record.filter_type == 'select'
    if query = record.query
      record.query_condition = query.filters 	
      if query.category_id
        record.query_condition||={}
        record.query_condition["category_id"] = query.category_id 
      end
    end  
  end
  
	validate do	|record|
    record.errors.add_to_base("标题不能为空") if  record.title.empty? 
    record.errors.add_to_base("请至少选择一个用例") if record.testcase_ids.empty?
    if record.category_id
	    if !record.project.line_home
	    	record.errors.add_to_base("属于基线库的测试集才能添加到回归集，你可以到基线库: #{record.project.product_line.name}线去试试") 
	    end
	  end
  end
  
  
	
	before_save do |record|
		#根据filter_type 清空相应的数据
    if record.filter_type
      # commented by zhushi 2010.4.26

      #assert [TYPE_SELECT,TYPE_FILTER].include?(record.filter_type), "unexpected filter_type: #{record.filter_type}"
      #if record.filter_type == TYPE_FILTER
      #  record.testcase_ids = []
      #else
        #record.query_condition = nil
      #end
    end
	end
		
	def self.find_all_exec_plan
		find(:all, :conditions => "exec_plan is not null").select{|e|e.exec_plan_now?}
	end
	
	def exec_plan_now?
		return false if self.exec_plan.blank?
		exec_hour =self.exec_plan['start_time']
		
		exec_now = if(wdays = self.exec_plan['wday'])
			#按周			
			wdays.include?(Date.today.wday.to_s) && exec_hour.to_s == Time.now.hour.to_s
		else
			#按天
			exec_hour == Time.now.hour.to_s
		end
		exec_now && last_job_done_or_canceled?
	end
	
	def last_job_done_or_canceled?
    return true if bgjob_suites.last.nil?
    [Auto::JobModule::STATE_CANCELED, Auto::JobModule::STATE_DONE].include? bgjob_suites.last.state    
	end
	

  def query
  	@query||= Query.create_by_testsuite(self)
  end
  
  def paginate_included_testcases(page, per_page=nil)
  		testcases.paginate(page, per_page)
  end
  
  def included_testcases
  		testcases
  end
  
  def included_testcases_count
  		testcases.count
  end
  
  def manual
  	true
  end
      

end
