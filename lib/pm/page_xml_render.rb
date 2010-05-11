class PageXmlRender
	def initialize(pm_model)
		@pm_model  = pm_model
		@root_node = pm_model.element_root
	end
	
	def render
		@root_node.submodels
		@root_node.elements
	end
end

