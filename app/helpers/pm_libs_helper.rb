module PmLibsHelper
	
	def boolean_display(value)
	  ["true", true, 1, "1"].include?(value)  ? "√" : "×"  
	end
	
	def html_type(pm_element)		
		the_type = pm_element.properties.html_type
  	element = PmElement.html_types.find{|e|e.last == the_type.to_s}
  	if element.nil?
  		logger.error "type #{the_type} should exists in #{PmElement.html_types.inspect}" 
  		PmElement.html_types.first.first
		else
			element.first	
		end
  	
	end
end
