class Auto::MachinesController < ApplicationController
  
	def index
		@machines = Machine.all(:conditions => "auto_user_id is null and machine_type = 1")
	end
	
	def new
		@machine = Machine.new
		@machine.ip = params[:machine][:ip]
		@machine.auto_user = User.current
		return unless request.post?
		if @machine.save
	  	flash["notice"] = "创建成功！"
	  	redirect_to :action => "show",:id => @machine
	  else
	  	#未成功
      render :action=>"index"	
  	end
	end
	
	def show
		@machine=Machine.find(params[:id])
	end

end
