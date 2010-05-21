require 'active_support'
##
# 项目在svn上的结构
# prject_root|
# 				   |001_场景名称|
# 												|01_script_name.xls
# 												|02_script_name.xls
#                         |01_script_name.rb
# 												|02_script_name.rb
#
##

module Scm::Sync
	#
	# Usage:　svn_root = File.expand_path("~/dev/tcommon-edge/product")
	#         Scm::Sync::FolderSynczer.new(svn_root).execute
	#
	#
	class FolderSynczer
		attr_reader :root, :logger
		
		def initialize(root, logger= RAILS_DEFAULT_LOGGER)
			@root = root
			@logger = logger
		end
		
		def self.project_id(path)
			array = path.chomp("/").split("/")
			proj = if(proj_i = array.index("projects"))
        line_id = find_home_project(array[proj_i-1]).line_id
        _proj = find_project( array[proj_i+1]  )
        assert _proj.line_id == line_id
        _proj
			else
				find_home_project(array.first)
			end
			assert proj
			proj.id
		end
		
		def self.id_of_path(array)
			array = array.chomp("/").split("/") if array.is_a? String
			assert array.last=~/^(\d+)_/, "#{array.last}"
			$1
		end

    def find_dups(array)
      array.uniq.map {|v| (array - [v]).size < (array.size - 1) ? v : nil}.compact
    end

		def execute
			before_pwd = Dir.pwd
			FileUtils.chdir(root)
			begin
				logger.info `svn up`
        start_at = Time.now
			  script_files = Dir["**/*_*.rb"].select{|e|File.basename(e) =~ /^(\d+)_(.+)\.rb$/}.map{|e|ScriptFile.new(e)}		  
				filenames = Dir["**/*_*.rb"].select{|e|File.basename(e) =~ /^(\d+)_(.+)\.rb$/}
        new_filenames = []
        filenames.each { |f| new_filenames << File.basename(f).split("_")[0] }
        dup_filenames = find_dups(new_filenames)
        if dup_filenames.size > 0
          logger.info "duplicate script: #{dup_filenames}"
          Utils.wangwang(["扬尘"], "SVN同步-脚本冲突", "脚本冲突: #{dup_filenames}")
        end

			  script_updates = script_files.build_hash{|e|[e.script_id, 
            {:script_path => e.path,
              :script => e.content,
              :updated_at=>Time.now,
              :col_titles=>e.col_titles,
              :author=>e.author,
              :author_id => 1}]}

        testcase_update	= script_files.map(&:testcase_entries).flatten.build_hash{|e|
					[e.testcase_id, {:data => e.data, :script_id => e.script_id}]
				}

        #duplicate testcase
        aa = script_files.map(&:testcase_entries).flatten.collect{|e| e.testcase_id.to_s+","+e.script_id.to_s}
        bb = find_dups(script_files.map(&:testcase_entries).flatten.collect{|e| e.testcase_id})
        cc = []
        dd = []
        bb.each do |b|
          aa.each do |a|
            if b == a.split(",")[0]
              cc << a
            end
          end
        end
        #        logger.info(cc)
        cc.each do |c|
          if Auto::Testcase.find_by_id_and_script_id(c.split(",")[0].to_i, c.split(",")[1].to_i).nil?
            dd << c
          end
        end
        if dd.size > 0
          dd.each do |d|
            logger.info "duplicate testcase: #{d}"
            testcase_id = d.split(",")[0]
            exist_script_id = Auto::Testcase.find(testcase_id).script_id
            exist_file = `find /var/www/twork/autotest/ -name #{exist_script_id}*.xls`
            exist_file = exist_file.gsub("/var/www/twork/autotest/", "")
            script_id = d.split(",")[1]
            duplicate_file = `find /var/www/twork/autotest/ -name #{script_id}*.xls`
            duplicate_file = duplicate_file.gsub("/var/www/twork/autotest/", "")
            Utils.wangwang(["扬尘", "云梦"], "SVN同步-用例冲突",
              "以下文件用例冲突：#{exist_file}和#{duplicate_file}。请修改文件：#{duplicate_file}！")
          end
        end


			  ActiveRecord::Base.transaction do		  	
					Auto::TestcaseScript.update_all("script_path=null, script=null")
          exsit_ids = ActiveRecord::Base.connection.select_values("select id from testcase_scripts")
          new_ids = script_updates.keys

          (exsit_ids - new_ids).each do|id|
            # to delete
            Auto::TestcaseScript.destroy(id)
          end

          (new_ids - exsit_ids).each do|id|
            # to create
            testscript = Auto::TestcaseScript.new(script_updates.fetch(id))
            testscript.id = id
            testscript.save!
          end

          (new_ids & exsit_ids).each do|id|
          	#to update
            Auto::TestcaseScript.update(id, script_updates.fetch(id))
          end

			  	Auto::Testcase.update_all("script_id=null")
			  	# Auto::Testcase.update(testcase_update.keys, testcase_update.values)			  	
			  	testcase_update.each do |key, value|
			  		if testcase = Auto::Testcase.find_by_id(key)
			  			testcase.update_attributes!(value)
		  			else
		  				logger.error "testcase: #{key}  not found!"
	  				end
			  	end
			  end	
			ensure
				FileUtils.chdir(before_pwd)
        end_at = Time.now
        logger.info "Used time: #{end_at-start_at}"
			end
			
			
		end
		
		private		
		def self.find_home_project(home_name)
			home_name.downcase!
			home_name = home_name+"_home" unless home_name.end_with?("_home")
			find_project(home_name.capitalize, :line_home => true)
		end
		
		def self.find_project(name, options={})
			options.reverse_merge!(:line_home=>false)
			result = all_project.find_all{|proj|
				ok = proj.qc_name == name && (proj.line_home? == options[:line_home])
				if options[:line_id]
					ok&&proj.line_id = options[:line_id]
				else
					ok
				end
			}
			if result.empty?
				raise "cannot find #{name } with options: #{options.inspect}"
			elsif result.size>1
				raise "found #{result.size} of project: #{name} with options: #{options.inspect}"
			else
				return result.first
			end
		end
		
		def self.all_project
			@all_project||=Project.all
		end
		
	end	
	
	class TestcaseEntry
		attr_accessor :testcase_id, :title, :data, :script_id
		
		def initialize(hash)
			hash.each{|k,v|self.send("#{k}=", v)}
		end
	end
	
	
	class ScriptFile
		extend ActiveSupport::Memoizable
		attr_reader :path , :testcase_entries, :col_titles
		
		def initialize(path)
			@path = path
			read_excel
		end
				
		def basename
			File.basename(real_path)
		end
		
		def content
			File.read(real_path).to_utf8
		end
		
		def project_id
			FolderSynczer.project_id(self.path)
		end
				
		def script_id
			FolderSynczer.id_of_path(self.path)
		end

		def real_path
			File.expand_path(path)
		end

    def author
      @author||=`svn info '#{real_path}'`.split("\n")[8].gsub("Last Changed Author: ", "")
    end
		
    private
    def read_excel
      excel_path = path.sub(/\.rb$/,'.xls')
      @testcase_entries = []
      if File.file?(excel_path)
        Scm::DataExcel.new(excel_path).process do |hash|
          @col_titles = hash[:titles]
          hash[:ids].each_with_index do |id, i|
            @testcase_entries << TestcaseEntry.new(:testcase_id=>"#{project_id}#{id}", :data => hash[:datas][i], :script_id => script_id)
          end
        end
      end
    end

    memoize :basename, :content, :real_path, :project_id, :script_id, :author
  end
end
