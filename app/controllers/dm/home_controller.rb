class Dm::HomeController < ApplicationController
  def index
  	DmConfig.setup_db_pool
  	@dm_config = params[:dm_config_id].blank? ? DmConfig.first : DmConfig.find(params[:dm_config_id])  	
  	db = @dm_config.database
  	@tables = db[:user_objects].select(:object_name).filter(:object_type=>"TABLE", :temporary=>"N")
  	begin
  		@result = db.execute(params[:sql])
  	rescue Exception => e
  		flash[:error] = e.message
  	end  	
  	render :action => "index"
  end 
  
  def execute_sql
  end
  
  def api
  	db  = params[:db]
  	statement = params[:statement]  
  	bind_values = params[:bind_values]
  	method = params[:m]||"execute"	
		#options = rtransf(params[:options])	
  	begin
  		conn = Dm::DbAccessor.instance.connection(db)
	  	result = if method == "read"
	  		#raise "db#{db}, statement#{statement}, bind_values#{bind_values.inspect}, :types => #{options[:types].inspect}"
	  		Dm::DbAccessor.instance.read(db, statement, bind_values, :types => options[:types])
	  	else
	  		conn.send(method, statement, bind_values)
	  	end 
	  	render :text => (result)
  	#rescue Exception => e  	
  	#	render :text => RuntimeError.new(e.message).to_yaml
  	end  	
  	
  end
  
  private
  
  def rtransf(v)
  	Marshal.load v
  end
  
  def transf(v)
  	Marshal.dump(v)
  end
end
