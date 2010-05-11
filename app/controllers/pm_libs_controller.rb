class PmLibsController < ApplicationController
  # GET /pm_libs
  # GET /pm_libs.xml
  def index
    @pm_libs = PmLib.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @pm_libs }
    end
  end

  # GET /pm_libs/1
  # GET /pm_libs/1.xml
  def show
    @pm_lib = PmLib.find(params[:id])  
    @folder_root = @pm_lib.folder_root                 
    respond_to do |format|
      format.html {
        raise "@folder_root is nil" if @folder_root.nil?
        redirect_to pm_lib_pm_folder_path(@pm_lib, @folder_root)
      }
      format.xml  { 
        render :xml => YAML.dump(Pm::LibVersion.new(@pm_lib).version_tree)
      }
    end

  end

  # GET /pm_libs/new
  # GET /pm_libs/new.xml
  def new
    @pm_lib = PmLib.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @pm_lib }
    end
  end

  # GET /pm_libs/1/edit
  def edit
    @pm_lib = PmLib.find(params[:id])
  end

  # POST /pm_libs
  # POST /pm_libs.xml
  def create
    @pm_lib = PmLib.new(params[:pm_lib])

    respond_to do |format|
      if @pm_lib.save
        flash[:notice] = 'PmLib was successfully created.'
        format.html { redirect_to(@pm_lib) }
        format.xml  { render :xml => @pm_lib, :status => :created, :location => @pm_lib }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @pm_lib.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /pm_libs/1
  # PUT /pm_libs/1.xml
  def update
    @pm_lib = PmLib.find(params[:id])

    respond_to do |format|
      if @pm_lib.update_attributes(params[:pm_lib])
        flash[:notice] = 'PmLib was successfully updated.'
        format.html { redirect_to(@pm_lib) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @pm_lib.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /pm_libs/1
  # DELETE /pm_libs/1.xml
  def destroy
    @pm_lib = PmLib.find(params[:id])
    @pm_lib.destroy

    respond_to do |format|
      format.html { redirect_to(pm_libs_url) }
      format.xml  { head :ok }
    end
  end
end
