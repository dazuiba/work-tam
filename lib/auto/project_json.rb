module Auto
  class ProjectJson     
    attr_reader :project
    def initialize(project)
       @project = project
    end                  
    
    def category_select_json                                                           
       result = {}
       level_1 = root.children
       level_2 = all_children(level_1) 
       level_3 = all_children(level_2)   
       result[:level_1] = level_1.map{|e|[e.id,e.title]}.to_json
       result[:level_2] = level_2.map{|e|[e.parent_id,e.id,e.title]}.to_json
       result[:level_3] = level_3.map{|e|[e.parent_id,e.id,e.title]}.to_json
       result
    end          

    
    def root
      @root||=project.testcase_categories.find(:first, :conditions=>{:parent_id => nil})
    end
    
    private
    
    def all_children(parents)
       @project.testcase_categories.find(:all, :conditions=>{:parent_id => parents.map(&:id)})  
    end                                                                                               
      
  end 
end
