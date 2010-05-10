class PmLib < ActiveRecord::Base
  validates_uniqueness_of :name
  has_many :pm_folders, :dependent => :destroy
  has_one  :folder_root, :class_name => "PmFolder", :conditions=>{:parent_id=>nil}

  def after_create
    self.build_folder_root(:name=>"Root", :title=>"Root").save!
  end
end
