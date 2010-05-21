class Auto::TestsuitesController < ApplicationController
  include SortHelper
  include Auto
  include Search
  before_filter :find_obj, :except => [ :index, :set_filter, :category_select, :list, :add, :new, :testplan, :search,:list_by_machine ,:get_sub_suite,:get_sub_case,:pick_down,:pick_up,:pick_up_do]

  def index
    line_id = if params[:line_id]
      cookies[:line_id] = {:value=>params[:line_id],:expires => 10.year.from_now}
      params[:line_id] 
    else
      cookies[:line_id]
    end 
    #    line_id ||=  
  	@product_line = line_id ? ProductLine.find(line_id) : ProductLine.first
  	@projects = @product_line.projects.scoped_by_auto(true)
    @base_project = @product_line.base_project
    params[:line_id] = line_id
  end  
  
  def show
  	@bgjob_suites = @testsuite.bgjob_suites.paginate :per_page => 30, :page => params[:page], :order => "created_at DESC"
  	@testcases = @testsuite.included_testcases.paginate :per_page => 20, :page => params[:page]
  end            

  def set_filter
    @testsuite = params[:id].blank? ? Testsuite.new : Testsuite.find(params[:id]) 
    retrieve_query
    render :partial=> "testcases", :object => @testcases
  end
 
  def new 
    @testsuite = Project.find(params[:project_id]).testsuites.build(params[:testsuite])
	  init_query(:replace => true)
    @testsuite.created_by = User.current
  	@testsuite.range_type = (params[:system].blank? ? 'user' : 'system')
    @testsuite.exec_plan =  params[:exec_plan] if params[:exec_plan]&&!params[:exec_plan]["start_time"].blank?
    @testsuite.plan_ip =  params[:plan_ip]

  	if request.get?
      inner_category_select
      return
    end

  	if params[:set_filter]
    	render :layout => !request.xhr?
	  else
	  	@testsuite.attributes = params[:testsuite]
	  	@testsuite.testcase_ids = params[:testcase_ids]
	  	if @testsuite.save
	  		flash[:notice] = "保存成功！"
	      redirect_to :action => "edit", :id => @testsuite.id
      else
	  		flash[:error] = "保存失败！"
        inner_category_select
	    end
  	end
  end
  
  def edit    
    inner_category_select
  	retrieve_query   
  end   
  
  def update
	  init_query(:replace => true)	
		@testsuite.attributes = params[:auto_testsuite]
		@testsuite.exec_plan =  params[:exec_plan] if params[:exec_plan]&&!params[:exec_plan]["start_time"].blank?
    @testsuite.plan_ip =  params[:plan_ip]
		@testsuite.testcase_ids = params[:testcase_ids]
    @testsuite.created_by = User.current
	  if @testsuite.save
	  	flash["notice"] = "保存成功！"
    	redirect_to :action => :show, :id => @testsuite
	  else
	  	flash["error"] = "保存失败！"
      self.edit
      render :action=>'edit'
  	end

  end

  def updateplan
		@testsuite.exec_plan =  params[:exec_plan]
	  if @testsuite.save
	  	flash["notice"] = "保存成功！"
    	redirect_to "/auto/testsuites/testplan"
	  else
	  	#未成功
      render :action=>"editplan"
  	end
  end

  def testplan
    if params["user"]
      session[:user] = exec_user_name =  params["user"]["nickname"]
    end
    if params["testplan"]
      session[:testplan] = title = params["testplan"]["title"]
    end
    conditions = test_plan_search(title,exec_user_name)
    @testplans = Testsuite.is_testplan.find(:all,:conditions => conditions).paginate(:page => params[:page], :per_page => 25)
  end

  def editplan
    render :layout => false
  end

  def cancel
    @testsuite.exec_plan = nil
    if @testsuite.save!      
      redirect_to "/auto/testsuites/testplan"
    end
  end
   
  def destroy
    #    assert request.delete?
    @testsuite.destroy
    flash[:notice] = "测试集【#{@testsuite.title}】删除成功！"
    respond_to do |format|
      format.html { redirect_to_line}
      format.xml  { head :ok }
    end
  end

  def list_by_machine
           
    suite_conditions = if params["bgjob"]
      session[:bgjob] = params["bgjob"]
      search_bgjob_list(params["bgjob"])
    else
      session[:bgjob] = ""
      "1=1"
    end
    
    case_conditions = if params["case"]
      session[:case] = params["case"]
      search_case_list(params["case"])
    else
      session[:case] = ""
      "suite_id = 0"
    end

    @suite_bgjobs = AutoBgjobSuite.find(:all,:conditions => suite_conditions,:order => "id DESC").paginate(:page => params[:page], :per_page => 25)
    @case_bgjobs = AutoBgjob.find(:all,:conditions => case_conditions,:order => "id DESC").paginate(:page => params[:page], :per_page => 25)
  end

  def pick_down
    Auto::TestcasesTestsuites.pick_down_bat params[:suites_and_case ],params[:id]
    flash["notice"] = "保存成功！"
    redirect_to(:action=>"show",:tab=>"testcases",:id=>params[:id])
  end
  
  def pick_up
    @product_line_id=params[:product_line]
    @pick_down_user=params[:pick_down_user]
    @pick_down_user = User.current.login if @pick_down_user.nil?
    @pick_down_at=params[:pick_down_at]
    @pick_down_cases = Auto::AutoTestReport.pick_down @product_line_id,@pick_down_user,@pick_down_at,params[:page]
  end
  
  def pick_up_do
    Auto::TestcasesTestsuites.pick_up_bat params[:suites_and_case ]
    flash["notice"] = "保存成功！"
    redirect_to(:action=>"pick_up",:product_line=>params[:product_line],:pick_down_user=>params[:pick_down_user],:pick_down_at=>params[:pick_down_at])
  end
  
  private

  def redirect_to_line(line_id=nil)
    redirect_to :action => "index", :line_id => line_id||@testsuite.project.line_id
  end

  def inner_category_select
    project = @testsuite ? @testsuite.project : Project.find(params[:project_id])
    project_json = Auto::ProjectJson.new(project)
    @root_category = project_json.root
    @category_json = project_json.category_select_json
  end
  
  def find_obj
    @testsuite = Testsuite.find(params[:id])
  end
  
  def init_query(options={})
    @query = @testsuite.query
    @query.project_id = @testsuite.range_id||params[:project_id]
    @category_trace = []
    if options[:replace]
      @query.filters={}
    end

    if params[:fields] and params[:fields].is_a? Array
      params[:fields].each do |field|
        @query.add_filter(field, params[:operators][field], params[:values][field])
      end
    end

    category_id = if params[:ClassLevel1]
      all = [params[:ClassLevel1], params[:ClassLevel2], params[:ClassLevel3]]
      all.reverse.find{|e|!e.blank?}
    elsif @testsuite.query_condition 
      @testsuite.query_condition["category_id"]
    end

    if category = (category_id.to_i>0 && TestcaseCategory.find_by_id(category_id))
      @query.category_id = category_id
    end
  end

  def retrieve_query(options={})
    init_query(options)

    if @query.project_id  		
      query_obj = Testcase.scoped_by_project_id(@query.project_id).scripted
    end

    if @query.category_id
      category = Auto::TestcaseCategory.find(@query.category_id)
      query_obj = query_obj.scoped(:conditions=>{:category_id => category.self_and_all_children_id})
      @category_trace = category.ancestors.reverse
      @category_trace.shift
      @category_trace << category
    end


    sort_init 'id', 'desc'
    sort_update({'id' => "id"})

    @testcases = query_obj.all(:conditions=>@query.statement)
  end

end
