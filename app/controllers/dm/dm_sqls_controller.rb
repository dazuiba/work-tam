class Dm::DmSqlsController < ApplicationController
  # GET /dm_sqls
  # GET /dm_sqls.xml
  def index
    @dm_sqls = DmSql.all
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @dm_sqls }
    end
  end        
  
  def to_sql_grid          
    render params.inspect
  end

  # GET /dm_sqls/1
  # GET /dm_sqls/1.xml
  def show
    @dm_sql = DmSql.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @dm_sql }
    end
  end

  # GET /dm_sqls/new
  # GET /dm_sqls/new.xml
  def new
    @dm_sql = DmSql.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @dm_sql }
    end
  end

  # GET /dm_sqls/1/edit
  def edit
    @dm_sql = DmSql.find(params[:id])
  end

  # POST /dm_sqls
  # POST /dm_sqls.xml
  def create
    @dm_sql = DmSql.new(params[:dm_sql])

    respond_to do |format|
      if @dm_sql.save
        flash[:notice] = 'DmSql was successfully created.'
        format.html { redirect_to(@dm_sql) }
        format.xml  { render :xml => @dm_sql, :status => :created, :location => @dm_sql }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @dm_sql.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /dm_sqls/1
  # PUT /dm_sqls/1.xml
  def update
    @dm_sql = DmSql.find(params[:id])

    respond_to do |format|
      if @dm_sql.update_attributes(params[:dm_sql])
        flash[:notice] = 'DmSql was successfully updated.'
        format.html { redirect_to(@dm_sql) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @dm_sql.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /dm_sqls/1
  # DELETE /dm_sqls/1.xml
  def destroy
    @dm_sql = DmSql.find(params[:id])
    @dm_sql.destroy

    respond_to do |format|
      format.html { redirect_to(dm_sqls_url) }
      format.xml  { head :ok }
    end
  end
end
