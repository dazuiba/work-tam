class PmModel < ActiveRecord::Base
   has_many :pm_elements
   belongs_to :pm_folder
   belongs_to :pm_lib
   belongs_to :owner
end
