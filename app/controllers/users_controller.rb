class UsersController < ApplicationController	 
   layout 'redmine'
   include UsersHelper
	 def modules
			if request.get?
				@modules = Menu.roots
				render_js
			else
				user = User.current
	   		user.config||={}
	   		user.config[:desktop]||={}
	   		user.config[:desktop].merge!(parse_modules_params)
	   	  user.save!
	   		render :json => {:success => "true"}.to_json
			end
	 end
	
	 def wallpaper
	 	 	 wallpapers = Dir["#{WALLPAPER_ROOT}/*.jpg"].map{|e|File.basename e}.map do |file|
	 	 	 		filename = File.basename(file)	 	 	 		
	 	 	 		num = Integer(/^(\d+)_/.match(filename)[1])
	 	 	 		{"wallpaperID"   			=>  num, 
	 	 	 		 "wallpaperName"      =>  File.basename(filename,".jpg"),
	 	 	 		 "wallpaperPath" 			=>  "resources/wallpapers/#{filename}",
	 	 	 		 "wallpaperThumbnail" =>  "resources/wallpapers/thumbnails/#{filename}"}
 	 	 	 end 	 	 	 
 	 	 	 render :json=>{"wallpapers" => wallpapers}.to_json
	 end
	    
   def profile
   	 
   end
   
   def show
      @user = User.find(params[:id])
   end
   
   # GET /users/list
   def list
      @users = User.find(:all)
   end
   
   def login
      @page_title="请登陆"
      return unless request.post?
      @login=params[:login]
      @user = User.find_by_login_and_password(@login, params[:password])
      return flash.now[:error] = l(:login_mismatch) if @user.nil?
      if @user.activated?
         self.logged_in_user=@user
         successful_login
      else
         flash.now[:error] = l(:not_activated_cannot_login)
      end
   end
   
   def logout
      logout_user
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
         redirect_to :action=>"list"
      else
         render :action => "edit"
      end
   end
   
   def change_password
      @user=User.find(params[:id])
      return unless request.post?
      if @user.update_attributes(params[:user])
         flash[:notice] = "#{@user.name}的密码已经更改，该用户的FTP密码将在1分钟后更新!"
         redirect_to :action=>"list"
      end
   end
   
   private
   
   def parse_modules_params   	
   	update_info = params.except(:task,:controller,:action)
   	if params[:task] == "wallpaper"
   		{"wallpaper" => update_info}
 		else
 			params.slice(params[:task])
 		end
   end
   
   def render_js
   		request.headers["Content-Type"] = "application/javascript" 
   		render :layout=>false
   end
   
end
