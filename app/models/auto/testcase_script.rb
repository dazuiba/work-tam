class Auto::TestcaseScript < ActiveRecord::Base
	has_many :testcases, :foreign_key => "script_id", :class_name => "Auto::Testcase", :dependent => :nullify
	belongs_to :category, :class_name => "Auto::TestcaseCategory"
	# after_create :syc_category_after_create
	# after_destroy :syc_category_after_destory
	# Default value is :
	#  ['title_1', 'title_2' ...]
	serialize :col_titles
	
	def filename
		File.basename self.script_path
	end
		
	def siblings
		self.class.scoped_by_category_id(self.category_id) - [self]
	end
	
	
  def clear_content!
    self.script=nil
    self.col_titles = nil
    self.testcases.each{|e|e.data = nil; e.save!}
    self.save!
  end
	
  def update_data!(new_tc_ids, col, datas)  	
  	assert_equal col.size, datas.first.size
  	
  	to_del = self.testcase_ids - new_tc_ids
  	to_del.each{|id|Testcase.find(id).clear_script!}
  	
  	new_tc_ids.each_with_index do|id, i|
  		tc = Testcase.find(id)
  		tc.data = datas[i]
  		assert tc.data.kind_of?(Array)
  		tc.save
		end

  	self.update_attributes! :col_titles => col
  end
  
  def clear_data
  	self.col_titles = nil
  	testcases.each{|e|e.clear_script!}
  end
  	
	#
	#{'title_1'=>xxx, 'title_2'=>yyy}
	#
	
	def data_row_for(testcase)
		result = testcase.data||self.col_titles.map{|e|nil}			
    result = result.build_hash_with_index{|e,i|[col_titles[i], "<font color='red'>#{e}</font>"]}
    result.merge(:id => testcase.id, "用例" => "<font color='red'>#{testcase.title}</font>")
	end
	
	def to_hash_csv
		DataCSV.new(:keys=>col_titles, :rows => tc.data )
	end
	#
	#options(optional)
	#	 index : insert to this index, 0 < index <array.size
	#	 col_title
	#
	def data_add_col!(options={})
		
		col_name = options[:col_title]||"title_#{self.col_titles.size}"
		if options[:index]
			assert options[:index]>=0 && options[:index] < col_titles.size
		end
		index = options[:index] || col_titles.size
		
		self.col_titles.insert(index, col_name)			
		testcases.each { |e| e.data.insert(index,nil);e.save!}
		self.save!
		self
	end
	
	def text
		"#{self.id}_#{self.title}.rb"
	end
	
	def leaf
		true
  end


  def self.current_tc_state(case_id)
    autoBgjob=Auto::AutoBgjob.find(:first,:conditions=>[" testcase_id=?",case_id],:order=>"id desc")
    return autoBgjob
  end
	
	private
	
	def syc_category_after_create
		#还有脚本，不需要detach
		return if siblings.size > 0
		TestcaseCategory.build_contains_auto( :id=>self.category_id,  :action=>:attach)
	end
	
	def syc_category_after_destory
		#还有脚本，不需要detach
		return if siblings.size > 0
		TestcaseCategory.build_contains_auto( :id=>self.category_id,  :action=>:detach)
	end
	
end
