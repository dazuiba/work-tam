class PmModelsController < ApplicationController

  live_tree :pm_elements_tree, :model => :pm_element
  
  # GET /pm_models
  # GET /pm_models.xml
  def index
    @pm_models = PmModel.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @pm_models }
    end
  end

  # GET /pm_models/1
  # GET /pm_models/1.xml
  def show   
    @pm_model = PmModel.find(params[:id])                        
    @element_root = @pm_model.element_root               
    raise if @element_root.nil?
    redirect_to pm_model_pm_element_path(@pm_model, @element_root)
  end

  # GET /pm_models/new
  # GET /pm_models/new.xml
  def new
    @pm_model = PmModel.new(params[:pm_model])

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @pm_model }
    end
  end

  # GET /pm_models/1/edit
  def edit
    @pm_model = PmModel.find(params[:id])
  end

  # POST /pm_models
  # POST /pm_models.xml
  def create
    @pm_model = PmModel.new(params[:pm_model])

    respond_to do |format|
      if @pm_model.save
        flash[:notice] = 'PmModel was successfully created.'
        format.html { redirect_to(@pm_model) }
        format.xml  { render :xml => @pm_model, :status => :created, :location => @pm_model }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @pm_model.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /pm_models/1
  # PUT /pm_models/1.xml
  def update
    @pm_model = PmModel.find(params[:id])

    respond_to do |format|
      if @pm_model.update_attributes(params[:pm_model])
        flash[:notice] = 'PmModel was successfully updated.'
        format.html { redirect_to(@pm_model) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @pm_model.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /pm_models/1
  # DELETE /pm_models/1.xml
  def destroy
    @pm_model = PmModel.find(params[:id])
    @pm_model.destroy

    respond_to do |format|
      format.html { redirect_to(pm_models_url) }
      format.xml  { head :ok }
    end
  end
end
