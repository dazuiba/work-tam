class Project < ActiveRecord::Base
	include Auto
	include Acts::Customizable
	
	#项目未关闭（默认）
	STATUS_ACTIVE     = 0	
	#项目已经关闭
  STATUS_CLOSED   = 1
	PROJECT_TYPE = {"ProjectOA" => "日常", "ProjectBase" => "基线库", "Daily" => "日常", 'TechProject'=>'技术选型', "CoreApp"=>"核心应用"}
	
  attr_accessor :not_a_qc_project
	has_many :members, :include => [:user, :role], :order => "roles.position"
  has_many :users, :through => :members
  has_many :testcases, :class_name => "Auto::Testcase"
  has_many :testcase_categories, :class_name => "Auto::TestcaseCategory"
  has_many :testsuites, :class_name => "Auto::Testsuite", :foreign_key => "range_id", :order => "id desc"
	validates_uniqueness_of :project_type, :scope => "line_id", :if => Proc.new { |project| project.line_home?||project.oa?}
	validates_uniqueness_of :qc_name, :scope => "line_home", :on => :create, :if => Proc.new { |project| project.line_home}
	validates_uniqueness_of :qc_db, :if => Proc.new { |project| !project.daily?&&!project.not_a_qc_project}
	validates_presence_of :name
	validates_presence_of :project_key, :if => Proc.new { |project| !project.not_a_qc_project}
	
  belongs_to :product_line, :class_name => "Base::ProductLine", :foreign_key => "line_id"
	belongs_to :product  
  
  #日常在wf上的id
  validates_uniqueness_of :project_key, :if => Proc.new { |project| project.daily? && !project.project_key.blank?}
	
  #@Deprecated
	#serialize :qc_config
	
	acts_as_customizable
	
	before_create do |record|
		if record.daily?
			if max_id = Project.find(:first, :conditions => {:project_type=>"Daily"} , :order => "id desc")
				record.id = max_id.id+1
			else
				record.id = 10001
			end
		else
			if max = Project.find(:first, :conditions => "project_type<>'Daily'", :order => "id desc")
				assert max.id <= 10000
				record.id = max.id+1
			else
				record.id = 1
			end
		end
	end
	
	
	before_validation  do |record|
		next if record.qc_name.blank?
		record.qc_name = record.qc_name.capitalize
		record.qc_db = record.qc_db.downcase
		if record.line_home? && !record.qc_name =~ /_home$/i
			record.qc_name = record.qc_name+"_home"
		end
		record.project_key||= record.qc_name
	end
	
	before_save do |record|
		record.project_type ||= case record.qc_db
		when /OA/i
			"ProjectOA"
		when /_home$/i
			"ProjectBase"
		else
			"Project"
		end		
	end
	
	before_create do|record|		
		record.status = STATUS_ACTIVE
	end
	
	def name
		if self.line_home?
			"基线库"
		elsif self.oa?
			"日常库"
		else
			super
		end
	end
	
	def project_type_text
		PROJECT_TYPE[self.project_type]
	end
	
	#日常库
	def line_home?
		project_type == "ProjectBase"
	end
	
	#日常库
	def oa?
		project_type == "ProjectOA"
	end
	
	def daily?
		project_type == "Daily"
	end

	def users_of_role(role)
		members.find_all_by_role_id(role).map(&:user)
	end
	
	# Commented by zhushi 2009-12-01
	# def qc_name
	# 	self.line_home? ? product_line.id_string : super
	# end
				
	def self.cut_project_id(id)
		idstring = id.to_s
		assert idstring.size>3
		return idstring[3,idstring.length]
	end
	
	def self.add_project_id(id,project_id)
		assert project_id.to_s.size == 3, "string size should be 3 but was #{project_id}"
		return "#{project_id}#{id}".to_i
	end
	
	
	def identifier_frozen?
		true
	end

	def qc_path
		product_line.id_string+"/"+ self.qc_name
	end
	
  def qc_model(clazz)
		if clazz.is_a? String
			clazz = "QC::Models::#{clazz}".constantize
		end
		QC::DbSupport.attach_project(self)
		clazz
	end
	
	def tc_importer
		QC::TCImporter.new(self)
	end
end
