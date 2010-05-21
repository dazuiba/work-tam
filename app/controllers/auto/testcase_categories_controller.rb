class Auto::TestcaseCategoriesController < ApplicationController
	include Auto	
  #  act_as_extjs_direct
  # GET /testc_categories
  # GET /testc_categories.xml

  def tree
    node_id, options = params[:data]
    result = if node_id && node_id!='root'
      father = TestcaseCategory.find(node_id)
      tree_as_json(father.category_leaf? ? father.testcases : father.children, false)
    else
      tree_as_json(TestcaseCategory.roots, true)
    end
    render_direct result, :no_root => true
  end
  

  # GET /testc_categories/1
  # GET /testc_categories/1.xml
  def show
  	cate_id = params[:id]
  	if name = params[:project_name]
			project = Project.find_by_qc_name name
			return render :status => 404, :text=>"404" if project.nil?
			cate_id = "#{project.id}#{cate_id}".to_i
		end
		
    @testcase_category = TestcaseCategory.find(cate_id)

    respond_to do |format|
      format.html 
      format.xml  { render :xml => @testcase_category }
    end
  end

  
  def testcases
  	@testcases = TestcaseCategory.find(params[:id]).testcases  	
  	respond_to do |format|
      format.xml  { render :xml => @testcases }
    end 
  end
  
  # GET /testc_categories/new
  # GET /testc_categories/new.xml
  def new
    @testcase_category = TestcaseCategory.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @testcase_category }
    end
  end

  # GET /testc_categories/1/edit
  def edit
    @testcase_category = TestcaseCategory.find(params[:id])
  end

  # POST /testc_categories
  # POST /testc_categories.xml
  def create
    @testcase_category = TestcaseCategory.new(params[:testcase_category])

    respond_to do |format|
      if @testcase_category.save
        flash[:notice] = 'TestcaseCategory was successfully created.'
        format.html { redirect_to(@testcase_category) }
        format.xml  { render :xml => @testcase_category, :status => :created, :location => @testcase_category }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @testcase_category.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /testc_categories/1
  # PUT /testc_categories/1.xml
  def update
    @testcase_category = TestcaseCategory.find(params[:id])

    respond_to do |format|
      if @testcase_category.update_attributes(params[:testcase_category])
        flash[:notice] = 'TestcaseCategory was successfully updated.'
        format.html { redirect_to(@testcase_category) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @testcase_category.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /testc_categories/1
  # DELETE /testc_categories/1.xml
  def destroy
    @testcase_category = TestcaseCategory.find(params[:id])
    @testcase_category.destroy

    respond_to do |format|
      format.html { redirect_to(testc_categories_url) }
      format.xml  { head :ok }
    end
  end
  
  def testcase_list
    @testcase_category_id = params[:id].to_i
    testcase_category = Auto::TestcaseCategory.find(@testcase_category_id, :select => "id, parent_id")
    @testcases = Auto::Testcase.find(:all, :select => "id, title, created_at, project_id, script_id",
      :conditions => ["category_id IN (#{display_categories_ids(testcase_category)})"],
      :order => "script_id DESC").paginate :per_page => 30, :page => params[:page]
  end

  private
  
  
  def tree_as_json(result, is_root )
  	json_options = {:only => [:id,:auto], :methods => [:text, :leaf], :include => [:children]}
    if is_root
      first = result.shift.expand_first_tree
      result = result.map{|e|e.as_json(json_options)}
      result.unshift first
    else
      result.as_json(json_options)
    end
  end

  def display_categories(categories, parent_id)
    ret = ""
    for category in categories
      if category.parent_id == parent_id
        ret << display_category(category)
      end
    end
    ret << ""
  end

  def display_category(category)
    ret = ""
    ret << category.id.to_s + " "
    ret << display_categories(category.old_children, category.id) if category.old_children.any?
    ret << ""
  end

  def display_categories_ids(category)
    display_category(category).rstrip.gsub(" ", ",")
  end
  
end
