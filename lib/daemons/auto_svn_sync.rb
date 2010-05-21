#!/usr/bin/env ruby
#title: SVN同步
#author: 柱石
require 'rubygems'
require File.dirname(__FILE__) + "/../../config/environment"
require File.dirname(__FILE__) + "/daemonable"
include CommandLine


class SyncWorker
	def self.sync(options={})
		if !options[:force] && execute("svn up", :chdir=>Setting.auto_server_svn_root) =~/^At revision/
			nil
		else
			Utils.report("脚本数量"=>"Auto::TestcaseScript.count", "绑定的用例数量"=>"Auto::Testcase.scripted.count") do
			Scm::Sync::FolderSynczer.new(Setting.auto_server_svn_root, options[:logger]).execute
			end
		end		
	end
end


logger = Daemonable.get_logger(__FILE__)
#首次执行

logger.info "First time: " + SyncWorker.sync(:force=>true, :logger=>logger).to_s
logger.close

#持续执行
Daemonable.runforever(__FILE__, 10) do |logger|
	logger.info("checking ...")
  if report = SyncWorker.sync(:logger=>logger)
  	logger.info "have file to sync..."
	  logger.info("Report: "+report.to_s)	 
	else
		logger.info "No update"
	end	
end
