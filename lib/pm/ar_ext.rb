module Pm
	module ARExt
	 
		module PmModelAttr
			def model_attr
				[["IsWeb", true], 
				 ["base", "HtmlModel"], 
				 ["modelNamespace", namespaces.join(".")], 
				 ["controltypeNamespace", "AWatir"]].build_ordered_hash
			end    
			
			def automan_class_name
			  name
			end
		end
		
		module PmElementAttr
			def method_attr                     
			   the_type =  if self.sub_model?        
			     model_type
		     else
			     automan_html_type(properties.html_type)
	       end
				 [["name", name],
				  ["type", the_type],
					["selector", properties.selector],
					["collection", properties.collection],
					["cache", "false"]].build_ordered_hash
			end
			
			def model_attr
				if self.root?
					[["type", self.pm_model.automan_class_name], ["Root", "true"]].build_ordered_hash
				else
					#assert !self.leaf?				
				  [["type", model_type], ["Root", "false"]].build_ordered_hash	
				end
			end                
			  
			
			protected     
			
			def model_type
			  assert self.sub_model?               
			  self.name.classify
			end
			
			def automan_html_type(html_type)
			  "AWatir::#{html_type}"
			end
		end
		
		module PmModelExt
		 include Pm::ARExt::PmModelAttr
	   def included(base)
	   		base.send :include, ActionController::UrlWriter
	 	 end
	 	 
	   def xml_render
	   	Pm::XmlRender.new(self)
	   end	   
	
	   def xml_file_name
	     "#{name}.xml"
	   end         
	 
	   def xml_file_url
	     pm_model_url(self, :format=>"xml")
	   end
	  end
	  
	end
end