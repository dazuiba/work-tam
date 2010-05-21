class DmConfig < ActiveRecord::Base
	set_table_name "dbconfigs"     
	named_scope :enabled, :conditions => {:disabled => false}
		
	
	def database
		Dm::DBPool[self.name]
	end
	
	def self.setup_db_pool		
		Dm::DBPool.setup(self.enabled.all.build_hash{|e|[e.name, e.connect_url]})
	end
	
	
	def connect_url
		if adapter == "oracle" 
			"oracle://#{user}:#{pwd}@#{db}/"
		else			
			"mysql://#{user}:#{pwd}@#{host}/#{db}"
		end			
	end		
end
