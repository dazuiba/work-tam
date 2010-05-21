class Auto::TestcaseCategory < ActiveRecord::Base
	acts_as_tree
	validates_presence_of :title
	belongs_to :project
	has_many :testcases, :foreign_key => "category_id", :class_name => "Auto::Testcase"
	has_many :scripts, :class_name => "Auto::TestcaseScript", :foreign_key => "category_id"
	
	def self.find_root_by_project_id(project_id)
		self.scoped_by_parent_id(nil).scoped_by_project_id(project_id)
	end
	
	def self.auto_tree
		 ActsAsTree.build_tree(find_all_by_contains_auto(true))
	end
	
	def expand_first_tree(options={:only => [:id,:auto], :methods => [:text, :leaf]})
		self.class.expand_first_tree(self,options)
	end
	
	def self.build_contains_auto(options=nil)
		options||={:id => TestcaseScript.all.map(&:category_id), 
						 :action => :rebuild}
    leaf_category_ids = Array(options[:id])
    
		all_ancestors_ids = leaf_category_ids.map{|e|
			ances = self.find(e).ancestors.map(&:id)
		}.flatten.uniq
		
		if options[:action]==:rebuild
			self.update_all("contains_auto = 0")
			self.update_all("contains_auto = 1", self.send(:sanitize_sql, :id => leaf_category_ids + all_ancestors_ids))
		elsif options[:action]==:attach
			self.update_all("contains_auto = 1", self.send(:sanitize_sql, :id => leaf_category_ids + all_ancestors_ids))
		elsif options[:action]==:detach
			self.update_all("contains_auto = 0", self.send(:sanitize_sql, :id => leaf_category_ids + all_ancestors_ids))
		else
			raise "option #{options.inspect} is not valid"
		end
	end
	
	def self.expand_first_tree(node,options={})
		result = node.as_json(options)	
		if(!node.leaf)
			children = node.children.dup
			first_child = children.shift
	
			first_child = expand_first_tree(first_child, options)
	
			result.merge!(:children =>children.as_json(options.slice(:only,:except,:methods)).unshift(first_child))
		end
		return result
	end
	
	def as_json_expand_all(options={})
		_children = old_children
		json_hash = self.as_json(options) 
		if category_leaf?
			json_hash.merge(:children => scripts_and_testcases.as_json(options))
		elsif _children.blank?
			json_hash 
		else
			json_hash.merge(:children=>children.map{|e|e.as_json_expand_all(options)})
		end
	end

  def self_and_all_children_id
    result = self.old_children.map{|e|e.self_and_all_children_id}.flatten
    result.unshift self.id
  end
	
  #####JSON METHODS######

	def text
		if category_leaf?
		 "#{Project.cut_project_id(self[:id])}_#{qc_title}"
	 	else
	 		self.qc_title
 	 	end
	end
	
	def qc_title
		if position&&self.parent_id			
			pos = position < 10 ? "0#{position}" : position.to_s
			"#{self.title}[#{pos}]"
		else
			self.title
		end
	end
	
	def category_leaf?
		old_children.empty?
	end
	
	alias :old_children :children
	
	def children
		if category_leaf?  
			testcases
		else
			old_children
		end
	end
	
	def scripts_and_testcases
		scripts + testcases
	end
	
	def old_children_with_fake
		@fake_children || old_children_without_fake
	end
	
	def children_with_fake
		@fake_children || children_without_fake
	end
	
	alias_method_chain :old_children, :fake
	alias_method_chain :children, :fake
	def fake_children=(children)
		@fake_children = children
	end
	
	def leaf
		self.category_leaf? && testcases.empty?
	end
	
end
