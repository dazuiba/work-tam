#!/usr/bin/env ruby
#title: 进程监控
#author: 柱石
$:.unshift(File.expand_path File.dirname(__FILE__)+"/../")
require 'rubygems'
require "daemons/daemonable"
require  "utils"
require  "ruby_extension"
require  'active_resource'
ActiveResource::Base.site = "http://twork.taobao.net:3003/admin"

Daemonable.runforever(__FILE__, 120) do |logger|
	module Admin;end
	include Admin
	class Admin::Daemon < ActiveResource::Base		
	end
	
  for daemon in Daemon.find(:all)
    if daemon.state == "down"
      file = File.expand_path(daemon.error_out)
      error_out = File.exists?(file) ? `tail -n#{50} #{file}`.chomp : "File not exists: #{daemon.error_out} "
      Utils.wangwang(["柱石", "宝驹", "云梦","扬尘"], "background job is down!", "以下进程挂掉: #{daemon.title}(#{daemon.ctl_name})，请及时维护。错误信息：#{error_out}")
      #      sleep(10*30)#给人工处理3分钟的时间
    end
  end

  staf_result = `STAF localhost PING PING`
  Utils.wangwang(["柱石", "扬尘"], "STAF进程挂掉", "STAF进程挂掉，请及时维护。") if staf_result.split("\n")[2] != "PONG"
end