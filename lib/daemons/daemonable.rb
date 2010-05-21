require 'rubygems'
require 'active_support'
require 'logger'
require 'timeout'
class Daemonable	
  CONFIG_FILE = "#{File.dirname(__FILE__)}/daemons.yml"
  RAILS_ROOT = File.expand_path File.join(File.dirname(__FILE__),"../../")
	
  def self.every_hour(file, &block)
    logger = get_logger(file)
  	logger.info "sleep #{60-Time.now.min} miniuts first!"
  	sleep((60-Time.now.min)*60)
  	self.runforever(file, 60*60, logger, &block)
  end
  
	def self.runforever(file, sleeptime=10,logger=nil, &block)	
	  Runner.new(file,sleeptime,get_logger(file)).run(&block)
	end

  def self.get_logger(file)
    if defined? ActiveRecord
      ActiveRecord::Base.logger.level = Logger::INFO
    end
    name = File.basename(file).split(".").first
    logger = Logger.new("#{RAILS_ROOT}/log/#{name}.log")
    logger.formatter = Logger::Formatter.new
    logger.datetime_format = "%Y-%m-%d %H:%M:%S"
    return logger
  end
		
	class Runner
		attr_accessor :file, :sleeptime, :logger
		def initialize(file, sleeptime, logger)
			self.file = file
			self.sleeptime = sleeptime
      self.logger = logger
			
		end
		
		def run			
	    $running = true
	    Signal.trap("TERM") do 
	      $running = false
	    end
	    
			while($running) do
				yield logger
				logger.info "Sleeping #{sleeptime}s ..."
				sleep_now
			end			
		end
		
		def sleep_now
			sleep(sleeptime)
		end
		
	end
	
end
