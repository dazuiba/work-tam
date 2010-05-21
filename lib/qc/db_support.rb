module QC	
	class Config
		cattr_accessor :included_models, :current_project
	end
	module DbSupport
	  def self.included(base)
	    base.extend(ClassMethods)	    
			base.send :establish_connection , :qc_user
	    base.send :include, InstanceMethods
	    
	    QC::Config.included_models||=Set.new
	    QC::Config.included_models<< base
	  end
	  
	  def self.attach_project(project)
	  		QC::Config.current_project = project
	  end
	  	
	  module ClassMethods
	  	
	  	def quoted_table_name
	  		table_name
	  	end
	  	
	  	def table_name
	  		"#{self.db_name}.#{self.qc_table_name}"
	  	end
	  	
	  	def db_name
	  		QC::Config.current_project.qc_db
	  	end
	  	
	  	def qc_table_name
	  		@qc_table_name||self.to_s.demodulize.tableize
	  	end
	  	
	  	def set_qc_table_name(tb)
	  		@qc_table_name = tb
	  	end
	  	
	  	def project
	  		QC::Config.current_project
	  	end
	  	
	  	private
	  	def date_range_sql(options={})
	  		start_date, end_date = nil, nil
	  		if options[:today]
	  			start_date = Date.today.beginning_of_day
	  			end_date   = Date.today.end_of_day
  			else
  				start_date = options[:start]
	  			end_date = options[:end]
				end
				start_date = convert_date(start_date)
				end_date = convert_date(end_date)
				if start_date.nil?
					"<= timestamp '#{end_date.to_s(:db)}'"
				elsif end_date.nil?
					">= timestamp '#{start_date.to_s(:db)}'"
				else
					"between timestamp '#{date.beginning_of_day.to_s(:db)}' and timestamp '#{date.end_of_day.to_s(:db)}' "
				end	  		
	  	end
	  	
	  	def convert_date(date)
	  		return date if date.nil?
	  		if date.respond_to? :localtime
	  			date.localtime
  			else
  				date
				end
	  	end
	  end
	
	  module InstanceMethods
	  	
	  end
	end
end