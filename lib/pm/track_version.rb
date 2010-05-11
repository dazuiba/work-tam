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
end