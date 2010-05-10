class PmModel < ActiveRecord::Base
   belongs_to :pm_folder
   belongs_to :pm_lib
   belongs_to :owners                 
   
   has_many :pm_elements
   has_one  :element_root, :class_name => "PmElement", :conditions=>{:parent_id=>nil}
   
   typed_serialize :properties, OpenStruct
   
   #create Root element
   after_create do |record|
     record.build_element_root(:name=>"Root", :title=>"Root").save!
   end  
   
   def pm_namespace
     self.pm_folder.namespaces.map{|e|e.name}.join(".")
   end
              
end
