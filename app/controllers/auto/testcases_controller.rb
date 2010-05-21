class Auto::TestcasesController < ApplicationController
	include ActionView::Helpers::NumberHelper
	include Auto
#  act_as_extjs_direct
  # GET /testcases
  # GET /testcases.xml
  def index
    @testcases = Testcase.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @testcases }
    end
  end
  
  def context_menu
  	@testsuite = Testsuite.find(params[:suite]) if params[:suite]
  end

	def list
		render_direct Testcase.paginate_by_category_id(params[:category_id],  :page => 1, :limit => params[:limit])
	end

  # GET /testcases/1
  # GET /testcases/1.xml
  def show    
		render_direct Testcase.find(params[:id])
  end

  # GET /testcases/new
  # GET /testcases/new.xml
  def new
    @testcase = Testcase.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @testcase }
    end
  end

  # GET /testcases/1/edit
  def edit
    @testcase = Testcase.find(params[:id])
  end

  # POST /testcases
  # POST /testcases.xml
  def create
    @testcase = Testcase.new(params[:testcase])

    respond_to do |format|
      if @testcase.save
        flash[:notice] = 'Testcase was successfully created.'
        format.html { redirect_to(@testcase) }
        format.xml  { render :xml => @testcase, :status => :created, :location => @testcase }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @testcase.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /testcases/1
  # PUT /testcases/1.xml
  def update
    @testcase = Testcase.find(params[:id])

    respond_to do |format|
      if @testcase.update_attributes(params[:testcase])
        flash[:notice] = 'Testcase was successfully updated.'
        format.html { redirect_to(@testcase) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @testcase.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /testcases/1
  # DELETE /testcases/1.xml
  def destroy
    @testcase = Testcase.find(params[:id])
    @testcase.destroy

    respond_to do |format|
      format.html { redirect_to(testcases_url) }
      format.xml  { head :ok }
    end
  end

  def show_testcase
    @testcase = Auto::Testcase.find(params[:id], 
      :select => "id, title, created_at, designer as old_designer, priority, script_id, data")
    @steps = @testcase.steps.paginate :per_page => 10, :page => params[:page]
    @script = @testcase.script
    @auto_bgjob = Auto::AutoBgjob.find(:first,
      :select => "exec_user_id, created_at, exec_result, result_log, reason_info",
      :conditions => [" #{Auto::JobModule::DONE} and testcase_id = ?",params[:id]],:order => "id desc")
    @auto_bgjobs = Auto::AutoBgjob.find(:all,
      :select => "id, testcase_id, exec_user_id, exec_result, created_at, started_at, done_at, exec_ip",
      :conditions => [" #{Auto::JobModule::DONE} and testcase_id = ?",params[:id]],:order => "id desc").paginate :per_page => 20, :page => params[:page]
  end

  def search
    tc_id = params[:tc_id].lstrip.rstrip
    tc_title = params[:tc_title].lstrip.rstrip
    str_sql = "SELECT id, title, created_at, project_id, script_id FROM testcases WHERE"
    if tc_id == "" and tc_title == ""
      str_sql += " 0"
    else
      (tc_id == "") ? (str_sql += " 1=1 AND") : (str_sql += " id LIKE '%#{tc_id}%' AND")
      (tc_title == "") ? (str_sql += " 1=1 AND") : (str_sql += " title LIKE '%#{tc_title}%' AND")
      @testcase_category_id = params[:tc_cid].to_i
      testcase_category = Auto::TestcaseCategory.find(@testcase_category_id, :select => "id, parent_id")
      str_sql += " category_id in (#{display_categories_ids(testcase_category)})"
    end
    @testcases = Auto::Testcase.find_by_sql(str_sql).paginate :per_page => 30, :page => params[:page]
  end

  private
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
