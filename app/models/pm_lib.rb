class PmLib < ActiveRecord::Base
  validates_uniqueness_of :name
  has_many :pm_folders
  has_one :folder_root, :class_name => "PmFolder", :conditions=>{:parent_id=>nil}
end
