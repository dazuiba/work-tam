class Admin::UsersController < Admin::ApplicationController
	
   def show
      @user = User.find(params[:id])
   end
   
   # GET /users/index
   def index
      #@users = User.find(:all)
      @users = User.paginate( :page=>params[:page]||1 ,:per_page => 20 )
   end
   
  
   #1  GET /users/new
   #2  POST /users/new params[:user]
   def new
      @user = User.new
      @page_title="新建用户"
      return unless request.post?
      @user = User.new(params[:user])
      if @user.save
         flash[:notice] = "用户 #{@user.name} 创建#{l 'success'}"
         redirect_to :action=>"list"
      end
   end

   #1 GET /users/1/edit
   #2 PUT /users/1/edit params[:user]
   def edit
      @user = User.find(params[:id])
      return unless request.post?
      if @user.update_attributes(params[:user])
         flash[:notice] = "更新#{l 'success'}"
         redirect_to :action=>"index"
      else
         render :action => "edit"
      end
   end
   
  
	
end

