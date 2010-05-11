module Pm
  module PageXml
    module InstanceMethods
      
    end
    class Render
    	def initialize(pm_model)
    		@pm_model  = pm_model
    		@root_node = pm_model.element_root
    	end
	
    	def render
    		@root_node.submodels
    		@root_node.elements
    	end
    end
  end      
end
