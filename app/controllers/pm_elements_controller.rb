class PmElementsController < ApplicationController

  
  live_tree :element, :model => :pm_element  
  # GET /pm_elements
  # GET /pm_elements.xml
  def index
    @pm_elements = PmElement.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @pm_elements }
    end
  end

  # GET /pm_elements/1
  # GET /pm_elements/1.xml
  def show
    @pm_element = PmElement.find(params[:id])      
    @pm_model = @pm_element.pm_model
    @element_root = @pm_model.element_root
    if request.xhr?
      render :partial => "show"
    else
    end
  end

  # GET /pm_elements/new
  # GET /pm_elements/new.xml
  def new
    @pm_element = PmElement.new(params[:pm_element])

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @pm_element }
    end
  end

  # GET /pm_elements/1/edit
  def edit
    @pm_element = PmElement.find(params[:id])
  end

  # POST /pm_elements
  # POST /pm_elements.xml
  def create
    @pm_element = PmElement.new(params[:pm_element]) 
    @pm_element.properties = OpenStruct.new params[:properties]
    respond_to do |format|
      if @pm_element.save
        flash[:notice] = 'PmElement was successfully created.'
        format.html { redirect_to(@pm_element) }
        format.xml  { render :xml => @pm_element, :status => :created, :location => @pm_element }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @pm_element.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /pm_elements/1
  # PUT /pm_elements/1.xml
  def update
    @pm_element = PmElement.find(params[:id])   
    @pm_element.properties = OpenStruct.new params[:properties]

    respond_to do |format|
      if @pm_element.update_attributes(params[:pm_element])
        flash[:notice] = 'PmElement was successfully updated.'
        format.html { redirect_to(@pm_element) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @pm_element.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /pm_elements/1
  # DELETE /pm_elements/1.xml
  def destroy
    @pm_element = PmElement.find(params[:id])
    @pm_element.destroy
    redirect_to pm_element_path(@pm_element.parent)
    
  end
end
