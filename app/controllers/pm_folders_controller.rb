class PmFoldersController < ApplicationController
  # GET /pm_folders
  # GET /pm_folders.xml
  def index
    @pm_folders = PmFolder.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @pm_folders }
    end
  end

  # GET /pm_folders/1
  # GET /pm_folders/1.xml
  def show
    @pm_folder = PmFolder.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @pm_folder }
    end
  end

  # GET /pm_folders/new
  # GET /pm_folders/new.xml
  def new
    @pm_folder = PmFolder.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @pm_folder }
    end
  end

  # GET /pm_folders/1/edit
  def edit
    @pm_folder = PmFolder.find(params[:id])
  end

  # POST /pm_folders
  # POST /pm_folders.xml
  def create
    @pm_folder = PmFolder.new(params[:pm_folder])

    respond_to do |format|
      if @pm_folder.save
        flash[:notice] = 'PmFolder was successfully created.'
        format.html { redirect_to(@pm_folder) }
        format.xml  { render :xml => @pm_folder, :status => :created, :location => @pm_folder }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @pm_folder.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /pm_folders/1
  # PUT /pm_folders/1.xml
  def update
    @pm_folder = PmFolder.find(params[:id])

    respond_to do |format|
      if @pm_folder.update_attributes(params[:pm_folder])
        flash[:notice] = 'PmFolder was successfully updated.'
        format.html { redirect_to(@pm_folder) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @pm_folder.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /pm_folders/1
  # DELETE /pm_folders/1.xml
  def destroy
    @pm_folder = PmFolder.find(params[:id])
    @pm_folder.destroy

    respond_to do |format|
      format.html { redirect_to(pm_folders_url) }
      format.xml  { head :ok }
    end
  end
end
