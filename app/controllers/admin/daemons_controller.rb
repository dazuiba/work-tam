class Admin::DaemonsController < Admin::ApplicationController
	
	def index
		@daemons = Daemon.all
		if state = params[:state]			
			@daemons=@daemons.select{|e|e.state==state}
		end
		respond_to do |format|
			format.html
			format.xml{render :xml=>@daemons}
		end	
	end
	
	def sync_all
		Daemon.sync_all
		redirect_to :action => "index"
	end
	
	def log
		@daemon = Daemon.find params[:id]
		render :layout=> !request.xhr?
	end
	
	def do_action
		@daemon = Daemon.find params[:id]
		action = params[:go]
		if @daemon.do_action(action)
			flash[:notice] = "#{action}成功！"
		else
			flash[:notice] = "#{action}失败！"
		end
		redirect_to :action => "index"		
	end
	
  def create
    @daemon = Daemon.new(params.slice(:ctl_name))
    if @daemon.save
      redirect_to :action => "index"
    else
      render :action => "new"
    end
  end


  def show
    @daemon = Daemon.find(params[:id])
    respond_to do |format|
    	format.html {}
      format.json { render_direct @daemon }
    end
  end

  def update
  end

  def destroy
    @daemon = Daemon.find(params[:id])
    @daemon.destroy

    render :update do |page|
      page[@daemon].replace_html :partial => "daemon_deleted", :object => @daemon
    end
  end

end
