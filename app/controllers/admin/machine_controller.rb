class Admin::MachineController < Admin::ApplicationController
  
  include CommonUtils
  
	def index
		@result = [:auto,	:perf, :other].map do |type|
			page = if (params[:tab] == type.to_s) && params[:page]
				[1,params[:page].to_i].max
			else
				1
			end
			[type, Machine.paginate_by_type(type, :page=> page)]
		end		
	end
	
	def new
		if request.get?
			type = (params[:type]||:other).to_sym
			sample_hash = if sample = (Machine.paginate_by_type(type, :order=>"id desc", :limit=>1).first)
				sample.attributes.except(:id)
			else
				{:machine_type=>:type, :ip=>"192.168."}
			end
	    @machine=Machine.new(sample_hash)
	    @machine.owner = User.current.nickname
		else
			@machine=Machine.new(params[:machine])
			if @machine.save
     	 flash[:notice] = "创建成功"   
			else
			 flash[:error] = @machine.errors.full_messages.join("<br>")
			end
   	  redirect_to_index(@machine)
		end
	end
	
  def edit
    @machine=Machine.find(params[:id])
    return unless request.post?
    if @machine.update_attributes(params[:machine])
      flash[:notice] = "更新#{l 'success'}"   
    else
    	flash[:error] = @machine.errors.full_messages.join("<br>")
  	end
    redirect_to_index(@machine)
  end
  
  
  def gem_package_upgrade
    if request.get?
      @machines_upgrade = Machine.order_unable_able
    end   
  end
  
  def gem_package_upgrade_doaction
      other_ip = Array.new
      other_ip = params[:other_ip].split(";") if params[:other_ip]
      arr_exec_ip = add_arr other_ip,params[:upgrade_ip]
      @exec_info_hash = Machine.gem_upgrade_bat arr_exec_ip,params[:cmd]
  end
  def gem_list
    @machine=Machine.find(params[:id])
    @gem_list_machine=@machine.gem_list
  end


  def host_info_read
      @ip=params[:host_ip]
      @exec_host_info = Machine.host_info @ip unless request.get?
  end

  def host_info_update
      @exec_host_info = Machine.host_info_update params[:host_ip] ,params[:host_info]
#      render :action => "host_info_read",:host_ip=>params[:host_ip]
  end

  def tns_info_read
      @ip=params[:tns_ip]
      @tns_add=params[:tns_add]
      @exec_tns_info = Machine.tns_info @ip , @tns_add unless request.get?
  end

  def tns_info_update
      @exec_host_info = Machine.tns_info_update params[:tns_ip] ,params[:tns_info],params[:tns_add]
  end
  
  private
  
  def redirect_to_index(machine, options={})
  	redirect_to :action=>"index", :tab=>machine.type_sym, :page=>params[:page]||1
  end
  
  def query_machine(type,options={})
    auto_user = "auto_user_id is null "
    auto_user = "auto_user_id is not null "if params[:type]
		@machines = Machine.all(:conditions => "#{auto_user} and machine_type = 1")
  end

end