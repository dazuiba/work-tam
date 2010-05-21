class Auto::TestcaseStepsController < ApplicationController
	include Auto	
  # GET /testcase_steps
  # GET /testcase_steps.xml
  def list
  	load 'lib/extjs_support.rb'
  	testcase = Testcase.find(params[:case_id])
    render_direct testcase.steps
  end

  # GET /testcase_steps/1
  # GET /testcase_steps/1.xml
  def show
    @testcase_step = TestCaseStep.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @testcase_step }
    end
  end

  # GET /testcase_steps/new
  # GET /testcase_steps/new.xml
  def new
    @testcase_step = TestCaseStep.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @testcase_step }
    end
  end

  # GET /testcase_steps/1/edit
  def edit
    @testcase_step = TestCaseStep.find(params[:id])
  end

  # POST /testcase_steps
  # POST /testcase_steps.xml
  def create
    @testcase_step = TestCaseStep.new(params[:testcase_step])

    respond_to do |format|
      if @testcase_step.save
        flash[:notice] = 'TestCaseStep was successfully created.'
        format.html { redirect_to(@testcase_step) }
        format.xml  { render :xml => @testcase_step, :status => :created, :location => @testcase_step }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @testcase_step.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /testcase_steps/1
  # PUT /testcase_steps/1.xml
  def update
    @testcase_step = TestCaseStep.find(params[:id])

    respond_to do |format|
      if @testcase_step.update_attributes(params[:testcase_step])
        flash[:notice] = 'TestCaseStep was successfully updated.'
        format.html { redirect_to(@testcase_step) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @testcase_step.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /testcase_steps/1
  # DELETE /testcase_steps/1.xml
  def destroy
    @testcase_step = TestCaseStep.find(params[:id])
    @testcase_step.destroy

    respond_to do |format|
      format.html { redirect_to(testcase_steps_url) }
      format.xml  { head :ok }
    end
  end
end
