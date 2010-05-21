#!/usr/bin/env ruby
#title: 机器监控
#author: 柱石
require 'rubygems'
require 'system_timer'
require File.dirname(__FILE__) + "/../../config/environment"
require File.dirname(__FILE__) + "/daemonable"

PING_TIME_OUT = 10
Daemonable.runforever(__FILE__, 5) do |logger|
  machines = Machine.auto_virtual
  last_ping_ok = machines.select{|e|e.ping_ok?}
  last_ping_fail = machines.select{|e|!e.ping_ok?}
  last_ping = last_ping_ok + last_ping_fail
  logger.info "Start to ping All !"
  threads = []
  thread_count = 10

  def chunk(array, number_of_chunks)
    chunks = (1..number_of_chunks).collect { [] }
    while array.any?
      chunks.each do |a_chunk|
        a_chunk << array.shift if array.any?
      end
    end
    chunks
  end

  number_of_last_ping = (last_ping.size/thread_count.to_f).round
  number_of_last_ping = (number_of_last_ping==0) ? 1 : number_of_last_ping
  logger.info number_of_last_ping
  chunk(last_ping, number_of_last_ping).each do |ms|
    ms.each do |m|
      threads << Thread.new(m) do |t|
        begin
          #          SystemTimer.timeout(PING_TIME_OUT){
          t.sync_state(logger)
          #          }
        rescue Timeout::Error
          logger.error "Timeout: #{t.ip}"
        end
      end
    end
    threads.each {|thr|
      begin
        thr.join
      rescue Exception => e
        logger.error e.message
        Utils.wangwang(["扬尘"], "机器监控-异常", "异常: #{e.message}")
      end
    }
  end

end