module QC	
	module Models
		
		#QC的项目， 访问的是qc_admin
		class QCProject  < ActiveRecord::Base
			establish_connection  :qc_admin
			set_primary_key "project_id"
			set_table_name "projects"
		end
		
		#测试用例
		class Test < ActiveRecord::Base
			include DbSupport
			set_primary_key "al_item_id"
			set_qc_table_name "test"
			##
			# 取得某用户在某项目下执行TC数
			#
			# usage：
			#  Project.find(161).qc_model("Test").execute_count(:login=>"nanfei", :date=>(Date.today))
			#
			# 一下所有xxx_count方法，用法类似
			#
			##
			def self.execute_count(query)
				##
				#参考：
				# Auction_home test表中的状态转换统计
					# "","No Run","6194"
					# "Failed","Passed","13"
					# "Failed","Not Completed","4"
					# "No Run","Failed","13"
					# "No Run","Passed","104"
					# "No Run","Not Completed","15"
					# "Passed","Failed","1"
					# "Passed","No Run","3"
					# "Passed","Not Completed","48"
					# "Not Completed","Failed","3"
					# "Not Completed","No Run","27"
					# "Not Completed","Passed","15"
				AuditLog.count_on("TEST",query,{"TS_EXEC_STATUS" =>[[:all,"Failed"], [:all,"Passed"]]})
			end
			
			##
			# 编写TC数
			# 
			##
			def self.create_count(query)
				AuditLog.count_on("TEST",query,{"TS_STATUS"=>:all})
			end
			
		end
		
		#缺陷
		class Bug < ActiveRecord::Base
			include DbSupport
			set_primary_key "bg_bg_id"
			set_qc_table_name "bug"			
			##
			# 验证的bug数
			##
			def self.confirmed_count(query)
				AuditLog.count_on("BUG",query)
			end
		end
		
		#修改记录
		class AuditLog < ActiveRecord::Base
			include DbSupport
			set_qc_table_name "audit_logs"
			def self.count_on(table, query, field_cond=nil)
				table.upcase!
				sql = %[select count( distinct prop.ap_property_id) from #{db_name}.audit_properties prop 
				left join #{db_name}.audit_log  log on (prop.ap_action_id = log.au_action_id)
				where prop.ap_table_name='#{table}'
						 #{property_id_in(query[:property_id_in])}
						 and log.au_user = ?
						 and #{field_cond_to_sql(field_cond)}
						 and log.au_time #{date_range_sql(query[:date]||:today)}]
				
				self.count_by_sql send(:sanitize_sql, [sql, query[:login].split(".").first])
			end
			
			private
			
			def self.property_id_in(property_id_in)
				return "" if property_id_in.nil?
				property_id_in = [-1] if property_id_in.size==0
				"property_id in (#{property_id_in})"
			end
			
			def self.field_cond_to_sql(cond)
				return '1=1' if cond.nil?
				
				cond.map{|k,v|					
					inner_cond = if v==:all
						'(1=1)'
					else
						 v.map{|e|
						 	old_c = e[0]==:all ? 	'1=1' : "ap_old_value = '#{e[0]}'"
						 	new_c = e[1]==:all ? 	'1=1' : "ap_new_value = '#{e[1]}'"
						 	"#{old_c} and #{new_c}"				 		 
					 	 }*" OR "
					end
					"(ap_field_name = '#{k}' and (#{inner_cond}))"
				}*" AND "
				
			end
		end
		
		
		
		#用例树
		class AllList < ActiveRecord::Base
			include DbSupport
			set_primary_key "al_item_id"
			
			def parent
	 		self.class.find(self.al_father_id) rescue nil
		 	end
		 			 	
		 	def children_and_self_ids
		 		children_ids + [self.id]
		 	end
		 	
		 	def children
		 		self.class.find_all_by_al_father_id(self.id, :order=> self.class.primary_key)
		 	end
		 	
		 	def ancestors_and_self
		 		ancestors+[self]
		 	end
		end		
		
	end
end