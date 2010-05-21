class PmElement < ActiveRecord::Base
	include Pm::ARExt::PmElementAttr
  belongs_to :pm_model
  acts_as_tree      
  
  typed_serialize :properties, OpenStruct
  track_version    
  
  validates_presence_of :name
  
  validates_uniqueness_of :name, :scope => [:parent_id]
 	
  named_scope :sub_models, :conditions=>{:leaf => false}
  named_scope :elements, :conditions=>{:leaf => true}        
  HTML_TYPES = [["默认", "AElement"], 
                 ["Button", "AButton"], 
                 ["Radio", "ARadio"], 
                 ["Checkbox", "ACheckbox"], 
                 ["Link", "ALink"], 
                 ["TextField", "ATextField"], 
                 ["SelectList"], "ASelectList"]  
  
  
  def self.html_types
    HTML_TYPES
  end    
  
  def sub_model?
    !self.leaf
  end
  
  
  def after_initialize
  	#缓存   
  	return false unless(defined? properties)
    if properties.cache.blank?
      properties.cache = false
    end  
    #集合
    if properties.collection.blank?
      properties.collection = false
    end    
    #必填
    if properties.required.blank?
      properties.required = false
    end      
  end
  
  before_create do |record|
    if record.pm_model_id.nil? && record.parent
      record.pm_model_id = record.parent.pm_model_id
    end
  end
                
  
  def traces
    result = ancestors.reverse.push(self)
    result
  end
  
  def name
  	if self.root?
      pm_name
    else     
      super
    end
  end
  
    
  def title
  	if self.root?
      pm_title
    else     
      super
    end
  end
  
  def pm_name
     pm_model.name
  end
    
  def pm_title
     pm_model.title
  end
  
  def tree_name
    name
  end        
  
end
