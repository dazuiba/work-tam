class Auto::Testcase < ActiveRecord::Base
  belongs_to :category, :class_name => "Auto::TestcaseCategory"
  belongs_to :script, :class_name => "Auto::TestcaseScript"
  belongs_to :designer, :class_name => "Base::User"
  belongs_to :auto_designer, :class_name => "Base::User"
  has_many :steps, :class_name => "Auto::TestcaseStep", :dependent => :delete_all
  belongs_to :project  
  has_and_belongs_to_many :testsuites
  
  has_many :bgjobs, :class_name => "Auto::AutoBgjob" 
  
  has_one :last_bgjob, :class_name => "Auto::AutoBgjob" ,:order => "id desc"
  
  serialize :data
  #目前所有数据均为自动化相关
  named_scope :auto , :conditions => "1=1"  
  named_scope :scripted , :conditions => "script_id is not null"  
  named_scope :case_title_like, lambda{|title|{:conditions => ["title like ?","%#{title}%"]}}
  def self.scope_with_condition(condition)
    with_scope(:find=>:all, :conditions => condition )
  end
  
  def self.designer
    designer_sql = "select distinct designer,nickname from testcases,users where designer is not null and users.login = designer order by designer"
    self.find_by_sql(designer_sql)
  end
  def self.priority
    priority_sql = "select distinct SUBSTRING(priority,1,2) as priority from testcases where priority is not null order by priority"
    self.find_by_sql(priority_sql)
  end
  def self.testcases_sort testcases,testsuites
    testcase_in_suite = Array.new
    testcase_not_in_suite = Array.new
    testcases.each do |testcase|
      if (Auto::TestcasesTestsuites.find_testcases_suites testsuites.id ,testcase.id).size !=0 then
        testcase_in_suite<<testcase
      else
          testcase_not_in_suite<<testcase
        end
      end
    return testcase_in_suite + testcase_not_in_suite
  end
  
  
    
  #####JSON METHODS######
	def text
    self.qc_title
	end
	
	def qc_title
		if position
			pos = position < 10 ? "0#{position}" : position.to_s
			"#{short_id}_#{self.title}[#{pos}]"
		else
			"#{short_id}_#{self.title}"
		end
	end
	
	def short_id
		Project.cut_project_id(self[:id])
	end
	
  def siblings
    self_and_siblings - [self]
  end

  def self_and_siblings
    category.testcases
  end

	def clear_script!
		self.data = nil
		self.script_id = nil
	end
	
	def leaf
		true
	end
end
