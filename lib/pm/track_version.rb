module Pm
	module TrackVersion 
	  def self.included(base)
	     base.extend(ClassMethods)
	  end
	  
	  module ClassMethods
	    def track_version     
	       include InstaceMethods
	       include "::Pm::TrackVersion::#{self.class_name.sub("Pm","")}".constantize  
	       after_save :do_track_version  
	       after_destroy :do_track_version
	    end
	  end
	  
	  module InstaceMethods
	    
	    def default_track_version
	      return if self.frozen?
	      return if (Time.now - self.updated_at.to_time)< 1
	      
	      puts "#{self.class} #{self.id}"
	      self.updated_at = Time.now  
	      self.send :update_without_callbacks                       
	    end
	    
	  end
	  
	  module Folder                 
	    def do_track_version   
	      default_track_version
	      if parent
	        parent.do_track_version
	      end
	    end
	  end
	  
	  module Model                    
	     def do_track_version   
	       default_track_version
	       
	       pm_folder.do_track_version
	     end
	  end
	  
	  module Element        
	    def do_track_version
	       pm_model.do_track_version
	    end
	    
	  end 
	  
	  
	end
	
	class LibVersion  
	  include Automan::Version	    
		def initialize(page_lib)
			@pm_lib = page_lib
		end
		
		def version_tree
			root = lib_to_vnode @pm_lib
			@pm_lib.folder_root.children.each{|e|add_node(root, e)}
			root
		end
		
		def add_node(parent_node, db_node)
			current_node = folder_to_vnode(db_node)
			parent_node.add_nodes(current_node)
			
			if !db_node.children.empty?
				db_node.children.each{|e|add_node(current_node, e)}
			elsif !db_node.pm_models.empty?
				db_node.pm_models.each{|e|current_node.add_nodes(model_to_vnode e)}
		  end
		end
		
		
		private
		
		def lib_to_vnode(pm_lib)
			folder_root = pm_lib.folder_root
			VersionRoot.new(version(folder_root), pm_lib.name)
		end
		
		def folder_to_vnode(folder)
			FolderNode.new(version(folder), folder.name )
		end     
		
		def model_to_vnode(model)
			FileNode.new(version(model), model.xml_file_name, model.xml_file_url )
		end
		
		def version(obj)
			obj.updated_at.to_s(:db)
		end
		
	end  
end