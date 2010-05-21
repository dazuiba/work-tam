#!/usr/bin/env ruby
#title: 脚本执行
#author: 柱石
require 'rubygems'
require File.dirname(__FILE__) + "/../../config/environment"
require File.dirname(__FILE__) + "/daemonable"

class AutoBgjobExe
	include CommandLine
	MAX_INTERVAL = 5
	EXE_TIME_OUT = 60 #second
	attr_reader :logger
	def initialize(logger)
		@logger = logger
	end
	
  def do_action
		jobs = Auto::AutoBgjob.find_all_jobs_to_run
		logger.info("Start a fresh fetch, #{jobs.size} jobs fetched")
		result = nil
		time = Benchmark.realtime {
			result = run_jobs(jobs)
		}
		logger.info("End of the fetch, #{jobs.size} jobs runned, #{ "%.2f" % time} used")  		
		if time <= MAX_INTERVAL
			logger.info("too fast, I must sleep to down grade mysql load")
			sleep MAX_INTERVAL
		end
  end
 
  private  
	def run_jobs(jobs)
    jobs.each do |job|
      assert job
	    job.set_state!(:running)
      logger.info("job #{job.id} start to running")
      begin
      	Timeout::timeout(EXE_TIME_OUT){
      		send_success = false
  	  	 	time = Benchmark.realtime{
            #            result_svn = execute("STAF #{job.exec_ip} PROCESS START SHELL COMMAND 'c:/new_setup.bat' FOCUS Minimized RETURNSTDOUT STDERRTOSTDOUT WAIT")
            #            if Regexp.compile(/(中发现冲突)/).match(result_svn)
            #              Utils.wangwang(["扬尘"], "脚本执行-SVN冲突", "机器IP: #{job.exec_ip}")
            #              job.result_log = result_svn
            #              job.exec_result = Auto::AutoBgjob::RESULT_SVN_FAILED
            #              job.set_state!(:done)
            #            else
            send_success = run_command(job.xml_path(:create),job.exec_ip).split("\n")[2].to_i > 0
            if !send_success
              job.exec_result = Auto::AutoBgjob::RESULT_STAF_FAILED
              job.set_state!(:done)
            end
            #            end
  				}
      		logger.info("Run job #{job.id} on #{job.exec_ip} suite:#{job.suite_id}, send_success?: #{send_success} Time used #{Utils.fmt_float(time) } . ")
    		}
      rescue Timeout::Error
      	logger.error("Run job #{job.id} on #{job.exec_ip} suite:#{job.suite_id}, timeout!")      	
      	job.exec_result = Auto::AutoBgjob::RESULT_STAF_TIMEOUT
        job.set_state!(:done)   	
      end      
    end
	end

  def run_command(staxml_path,exec_ip)
  	result = nil
  	time = Benchmark.realtime{
    	result = execute(%[STAF local STAX EXECUTE FILE  #{staxml_path}  SCRIPT "local='#{exec_ip}'"  CLEARLOGS]) 
	 	}
  	logger.info "#{time} used on command result #{result.inspect}"
  	
  	return result
  end
	
end



Daemonable.runforever(__FILE__, 10) do |logger|
	logger.info("Run Jobs ...")  
	AutoBgjobExe.new(logger).do_action
end
