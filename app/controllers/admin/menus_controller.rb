class Admin::MenusController < Admin::ApplicationController

  before_filter :find_menu, :except => [:index, :new, :index]
  include Base
  def new
  	@menu = Menu.new(params[:menu])
  	if request.get?
  		return render(:layout=> !request.xhr?) 
  	end
		if @menu.save
			flash["notice"] = "保存成功！"
 		 	redirect_to_menu(@menu.parent_id)
		else
			flash["error"] = "保存项目时失败"	
		end
  end
  
  def index
  	@menu = Menu.new(:name=>"Root")
  	@children = Menu.roots
  	render :action => "show"
  end
  	
  # Show @menu
  def show  	
  	@children = @menu.children
  end
  
  def update
  	@menu[params[:key]] = params[:value]
  	if @menu.save
			render :text=>params[:value]
		else
	  	render :update, :status => 400 do |page|
	  			page.alert "非法输入\n："+@menu.errors.full_messages.join("\n")
			end
		end
		
  end
  
  # Edit @menu
  def edit
    if !request.get?
      @menu.attributes = params[:menu]
      if @menu.save
        flash[:notice] = l(:notice_successful_update)
        redirect_to :action => 'settings', :id => @menu
      else
        settings
        render :action => 'settings'
      end
    end
  end
  
   
  def destroy
  	@menu.destroy
  	flash[:notice] = "删除成功!"  	
  	redirect_to_menu(@menu.parent_id)
  end
  
  def redirect_to_menu(id)
  	if id.blank?
  		redirect_to :action => "index"
		else
  		redirect_to(:action=>"show", :id=>id)
		end
  end
	
  private
  # Find menu of id params[:id]
  # if not found, redirect to menu list
  # Used as a before_filter
  def find_menu
  	if params[:id].blank?
  		redirect_to :action => "index" 
  		return false
  	end
    @menu = Menu.find(params[:id])
  end
end
