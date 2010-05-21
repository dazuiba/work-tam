class Menu < ActiveRecord::Base
		acts_as_tree
		validates_presence_of :name
		validates_format_of :url, :with => /^(\/|http(s?):\/\/)/, :message => "is invalid", :unless=>Proc.new { |menu| menu.url.blank? }
		validates_uniqueness_of :name, :scope=>"parent_id", :unless=>Proc.new { |menu| menu.name.blank? }
		validates_uniqueness_of :url, :scope=>"parent_id", :unless=>Proc.new { |menu| menu.url.blank? }
		validates_uniqueness_of :id_string, :scope=>"parent_id", :unless=>Proc.new { |menu| menu.id_string.blank? }
		validates_format_of :inner_url, :with => /^(\/|http(s?):\/\/)/, 
		                                :message => "is invalid", 
		                                :unless=>Proc.new { |menu| menu.inner_url.blank? }
		def self.find_root_menu(m)
			find_by_id_string_and_parent_id(m,nil)
		end
		
end