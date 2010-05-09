class PmElement < ActiveRecord::Base
  belongs_to :pm_model
  acts_as_tree      
  
  typed_serialize :properties, Hash
end
