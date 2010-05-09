class PmFolder < ActiveRecord::Base      
  has_many :pm_models
  acts_as_tree
  def tree_name; name ; end
end
