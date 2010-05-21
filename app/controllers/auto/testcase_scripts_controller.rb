class Auto::TestcaseScriptsController < ApplicationController
	include Auto	
  def index  	
  end
  
  def csv
  	
  end
  
  def create
    @script = TestcaseScript.new(params[:testcase_script])

    respond_to do |format|
      if @script.save
        format.xml  { render :xml => @script, :status => :created}
      else
        format.xml  { render :xml => @script.errors, :status => :unprocessable_entity }
      end
    end
  end

  def show
    testcase = Testcase.find(params[:case_id])
    return render_direct Hash.new unless testcase.script
  	result  = testcase.script.as_json 
    autoBgjob=Auto::TestcaseScript.current_tc_state params[:case_id]
    result[:state] = autoBgjob.nil? ? "" : autoBgjob.state
    result[:nickname] = User.current.nil? ? "" : User.current.nickname
  	 respond_to do |format|
      format.json { render_direct result }
      format.xml  { render :xml => result }
    end 
  end
  
 
  def load_data
	current_testcase = Testcase.find(params[:case_id])
    if script = current_testcase.script
    	data = script.data_row_for(current_testcase)
      arr_data=Array.new
      arr_data<<data
			render_direct arr_data do |result|
				result[:metaData] 					= {"id"=> "id","totalProperty" => "total" , "root" => "data"}
        result[:metaData]["fields"] = field_meta(result[:data])
        testcase_column             = {:header => "用例",:dataIndex => "用例"}
        result[:columns]						= script.col_titles.map{|e|{:header => e, :dataIndex => e}}.unshift(testcase_column)
			end
			
    else 
    	render_direct Hash.new 
    end	
  end
  	
  def new
    script = TestcaseScript.find_or_create_by_category_id(params[:category_id])
		render_direct script 
  end
	
  def add_col
  	script = TestcaseScript.find(params[:id])
  	script.data_add_col!(params.slice(:col_title, :index))
  	render_direct script.as_json(:methods => [:data_grid])
  end
  
  def edit
    script = TestcaseScript.find(params[:id])
    render_direct script 
  end


  def update
    @script = TestcaseScript.find(params[:id])
    
  end
  
  def destroy
    @script = TestcaseScript.find(params[:id])
    @script.destroy
  end
end
