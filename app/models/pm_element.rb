class PmElement < ActiveRecord::Base
  belongs_to :pm_model
  acts_as_tree      
  
  typed_serialize :properties, OpenStruct
  track_version
 	
  named_scope :submodels, :conditions=>{:leaf => false}
  named_scope :elements, :conditions=>{:leaf => true}
  
  before_create do |record|
    if record.pm_model_id.nil? && record.parent
      record.pm_model_id = record.parent.pm_model_id
    end
  end              
  
  def traces
    result = ancestors.reverse.push(self)
    result
  end
  
  def pm_name
     pm_model.name
  end
  
  def pm_title
     pm_model.title
  end
  
  def tree_name
    if self.root?
      pm_name
    else     
      name
    end
  end        
  
end
