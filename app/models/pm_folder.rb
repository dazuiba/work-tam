class PmFolder < ActiveRecord::Base      
  has_many :pm_models, :dependent => :destroy
  belongs_to :pm_lib
  acts_as_tree    
  track_version
  def tree_name;
  	if self.root?
  		pm_lib.name
		else
  	  name 
  	end   	 
	end        
  
  def namespaces
    result = ancestors.reverse.push(self)
    result.shift
    result
  end
  
  before_create do |record|
    if record.pm_lib_id.nil? && record.parent
      record.pm_lib_id = record.parent.pm_lib_id
    end
  end
  
end
