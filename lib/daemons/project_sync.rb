#!/usr/bin/env ruby
#title: 项目同步
#author: 柱石
require 'rubygems'
require File.dirname(__FILE__) + "/../../config/environment"
require File.dirname(__FILE__) + "/daemonable"
require 'qc/models'
class ProjectSync
  include QC::Models
	attr_accessor :start_id, :logger
	def initialize(options={})
		start_id = Setting.last_sync_qcproject_id
		@start_id = start_id.to_i == 0 ? 206 : start_id
		@logger = options[:logger]||Logger.new("#{RAILS_ROOT}/log/qc_project_sync.log")
	end
	
	def sync
		qc_projects = QCProject.find(:all, :conditions => ["project_id > ?", start_id] , :order => "project_id")
		
		return if qc_projects.empty?
																		  																  
		qc_projects.each do |qc_project|
			proj = Project.find_or_initialize_by_qc_db(qc_project.db_name)
			if proj.new_record?
				line = find_or_create_line(qc_project.domain_name)
				proj.qc_name = qc_project.project_name
				proj.name = proj.qc_name
				proj.product_line = line
				if proj.save
					@logger.info "Sync project Success : #{proj.id}, #{proj.name}"
				else
					@logger.error "Sync project saving error: #{proj.errors.full_messages.join(';')}"
				end
				
			else
				@logger.info "Ignore Project: #{qc_project.project_name}"
			end
		end
		
	  Setting.last_sync_qcproject_id = qc_projects.last.project_id
	  @logger.info "set Setting#last_sync_qcproject_id = #{qc_projects.last.project_id}"
	  true			
	end
	
	private		
	
	def find_or_create_line(key)
		line = Base::ProductLine.find_or_initialize_by_id_string(key.upcase)
		if line.new_record?				
			@logger.info "Create ProjectLine: #{key}"
			line.name = line.id_string
			line.save!
		end
		line
	end
	
end

Daemonable.runforever(__FILE__, 60*10) do |logger|
	logger.info("Run Jobs ...")  
	ProjectSync.new(:logger=>logger).sync
end
