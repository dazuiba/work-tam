class Admin::ProjectsController < Admin::ApplicationController

  before_filter :find_project, :except => [:product_projects, :new, :index, :list, :add, :show_project, :show_task, :show_users, :change_password]
  
  include Base
  def new
  	@project = Project.new(params[:project])
  	if request.get?
  		return render(:layout=> !request.xhr?) 
  	end
  	@project.not_a_qc_project = true if(params[:link_qc].nil?)		   
		if  @project.save
			flash["notice"] = "保存成功！"
			redirect_to_line(@project.line_id)
		else
			flash["error"] = "保存项目时失败"	
		end
  end
  
  
  def product_projects
  	@product = Base::Product.find(params[:id])
  	if request.get?
	  	@projects = @product.projects  	
	  	render(:layout=> !request.xhr?) 
	  else
	  	@product.project_ids = params[:projects]
	  	if @product.save
	  		render(:update){|page|page.alert("保存成功")}
  		else
  			render(:update){|page|page.alert("保存失败")}
			end
  	end
  end
  
  
  def index
  	@line         = ProductLine.find(params[:line_id]||=1)
  	@projects     = @line.projects.scoped_by_line_home(false).paginate(:page=>params[:page]||1 ,:per_page => 20)
  	@daily_array  = @line.daily_array.paginate(:page=>params[:page]||1 ,:per_page => 20)
  	@tech_projects  = @line.tech_projects.paginate(:page=>params[:page]||1 ,:per_page => 20)
  end
  	
  # Show @project
  def show
    @members_by_role = @project.members.find(:all, :include => [:user, :role]).group_by {|m| m.role}
  end

  def settings
    @member ||= @project.members.new
    if params[:tab].to_s == "qc_sync"
    	project = Project.find(params[:id])
    	if project.qc_db.blank?
    		flash[:notice] = "该项目没有关联QC！"
  		else
  			begin
        	@testcases = project.tc_importer.import_preview!
      		flash[:notice] = "qc同步预览成功！"
	      rescue Exception => e
	        flash[:notice] = "qc同步预览失败！<br> #{e.message}"
	      end
			end
    end
  end

  def qc_import
	 	begin
		 	report = Project.find(params[:id]).tc_importer.import!
			flash[:notice] = "qc同步成功，#{report}"	
	 	rescue QC::Error => e
	 		flash[:notice] = "qc同步失败！<br> #{e.message}"	
	 	end
		
		redirect_to :action => "settings", :id=>params[:id], :tab=>"info"
  end
  
  # Edit @project
  def edit
    if !request.get?
      @project.attributes = params[:project]
      if @project.save
        flash[:notice] = l(:notice_successful_update)      
      else
      	flash[:error] = "保存失败"
    	end
      redirect_to :action => 'settings', :id => @project, :tab => params[:tab]||'info'
    end
  end
  
   
  def destroy
    assert request.delete?
    error = nil
    
    if(count=@project.testcases.count)>0
    	error = "还包含活跃用例#{count}个， 不能删除！"
  	else
  		if @project.line_home?
  			if @project.product_line.projects.size>1
  				error = "此基线还包含个， 不能删除！"
  			end
  			@project.product_line.destroy
			else				
				@project.destroy
			end
			
    	flash[:notice] = "删除成功！"
		end
		
    respond_to do |format|
      format.html { redirect_to_line(@project.line_id) }
      format.xml  { head :ok }
    end
  end
	
  private
  
  def redirect_to_line(line_id)
  	redirect_to :action => "index", :line_id=>line_id
  end
  
  # Find project of id params[:id]
  # if not found, redirect to project list
  # Used as a before_filter
  def find_project
    @project = Project.find(params[:id])
  end
end
