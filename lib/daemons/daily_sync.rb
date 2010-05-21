#!/usr/bin/env ruby
#title: 日常同步
#author: 柱石
require 'rubygems'
require File.dirname(__FILE__) + "/../../config/environment"
require File.dirname(__FILE__) + "/daemonable"
require 'qc/models'

ProductLineNotParsed =  Class.new(RuntimeError)
class DailySync
		require 'xmlsimple'
		attr_accessor :url,:from_date, :to_date
		def initialize(options={})
			@url = options[:url]||Setting.wf_daily_url
			@from_date = 1.month.ago.to_date
			@to_date   = 1.month.from_now.to_date
			@logger = options[:logger]||Logger.new("#{RAILS_ROOT}/log/wf_daily_sync.log")
		end
		
		def sync
			cmd = "curl '#{url}?starttime=#{from_date.to_s(:db)}&endtime=#{to_date.to_s(:db)}'"
			@logger.info "get: #{cmd} "
			out = `#{cmd}`
			xml = XmlSimple.xml_in(out)
			xml["daily"].each do |daily|
				id = daily["id"].to_i
				assert id > 10000
				if strip(daily["status"].first) == "需求已发"
					if project = ::Project.find_by_project_key(id)
						project.status = ::Project::STATUS_CLOSED
						project.save!
					end
					next
				end
				
				next if daily["members"].first["test"].first.blank?
					
				#已经分配测试人员
				begin
					create_daily(id, daily)						
				rescue ProductLineNotParsed => e
					#不能关联产品线
					@logger.warn "#{e.message}. daily: #{daily["title"].first}"
				end	
					
				
			end
		end
		
		def create_daily(id,daily)
		  assert id
		  name = daily["title"].first.strip
		  #为防止name重复，特做以下处理
			tw_daily = ::Project.find_by_project_key(id)
			if tw_daily.nil?
			  tw_daily = ::Project.find_or_initialize_by_project_type_and_name("Daily", name)
			  tw_daily.project_key = id
		  else
		   	tw_daily.attributes = {:project_type => "Daily",
									  					 :name => name}			
			end
			
			if tw_daily.new_record?
				members = parse_members(daily["members"].first)
				tw_daily.line_id = parse_product_line_id(members)
				members.each{|e|
					e.project = tw_daily;
					if e.save
						@logger.debug "save member #{e.inspect}"
					else
						@logger.error "Error: save member #{e.errors.full_messages.join(';')}"
					end
				}
			else	
				tw_daily.save!
			end
		end
		
		private
		
		def parse_product_line_id(members)
			incharge_member = members.find{|e|e.role_id == ::Role::TEST_IN_CHARGE}
			raise(ProductLineNotParsed,"开发自测") if incharge_member.nil?
			
			result_member = Member.find(:first, :conditions=> {:role_id    => ::Role::TEST_IN_CHARGE, 
																			 :project_id => Project.find_all_by_project_type("ProjectOA").map(&:id),
																			 :user_id    => incharge_member.user.id})
			raise(ProductLineNotParsed,"test_in_charge没有设置") if result_member.nil?
			
		  result_member && result_member.project.line_id
		end
		
		#member_raw
		#{"testincharge"=>["sam"], "tl"=>["lee"], "pdm"=>["be"], "test"=>[{}], "dev"=>["ha"]}
		def parse_members(member_raw)
			member_raw.map do |role, value|
				if value.respond_to?(:to_a)	
				   value = value.to_a.first if value.to_a.size<=1
				end
				next if value.blank?
				raise value.inspect unless value.is_a? String

				role = Role.find_by_symbol(role.strip)
				users = split_token(value).map{|e|e.blank? ? nil : User.find_by_nickname(parse_nickname(e))}.compact
				if role && !users.empty?
					users.map{|user|Member.new(:role => role, :user=>user)}
				end
			end.compact.flatten
		end
		
		def parse_nickname(e)
			strip e.gsub(/（.+）/,"").gsub(/\(.+\)/,"")
		end

		def strip(string)
			if string.respond_to?(:to_a) && string.to_a.size==0
				return ""
			end
			string.strip.gsub(/　/,"")
		end
	
		def split_token(c)
			c.split(/,|，/)
		end
end
if /daily_sync_ctl$/ =~ $0
	Daemonable.runforever(__FILE__, 60*30) do |logger|
		logger.info("Run Jobs ...")  
		DailySync.new(:logger=>logger).sync
	end
end
