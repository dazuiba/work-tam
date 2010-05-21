class Daemon < ActiveRecord::Base	
	extend ActiveSupport::Memoizable
	include CommandLine
	validates_presence_of :ctl_name
	validates_uniqueness_of :ctl_name, :on => :create, :message => "must be unique"
	PID_DIR = "#{RAILS_ROOT}/tmp/pids"
	FILE_DIR = "#{RAILS_ROOT}/lib/daemons"
	LOG_DIR = "#{RAILS_ROOT}/log"
	
	def self.sync_all
		names = self.all.map(&:ctl_name)
		files = Dir["#{FILE_DIR}/*_ctl"].map{|e|File.basename(e)}
		if (files - names).size+(names - files).size >0
			self.delete_all
			files.each{|e|
				obj = self.new(:ctl_name=>e)
				content_lines = File.readlines(obj.rb_file)
				title = content_lines[1].split(":").last.strip
				author = content_lines[2].split(":").last.strip
        obj.attributes = {:title => title, :author=> author}
        obj.save!
			}
		end
	end
	
	def started_at
		File.exists?(pid_file)&&File.stat(pid_file).mtime
	end
	
	def updated_at
		File.exists?(log)&&File.stat(log).atime
	end	

  def rb_file
    File.join(FILE_DIR, self.ctl_name.chomp("_ctl")+".rb")
  end
	
	def do_action(action)
		execute "rm #{error_log} #{error_out} #{log} -f "
		execute "ruby #{FILE_DIR}/#{ctl_name} #{action}"
	end	
	
	def duration
		if self.started_at && self.updated_at
			(self.updated_at - self.started_at).ceil
		end
  end	
	
	def state
		(mem && mem>0) ? "running" : "down"
	end
	
	def mem
	 	if pid && _mem = execute("ps -o rss= -p #{pid}")
	 		return _mem.chomp.to_i*1024 if !_mem.blank?
 		end
	end
	
	def pid		
		File.exists?(pid_file) && File.read(pid_file).chomp
	end
	
	def pid_file
		"#{PID_DIR}/#{self.ctl_name}.pid"
	end
	
	def error_log
		"#{PID_DIR}/#{self.ctl_name}.log"
	end
	
	def error_out
		"#{PID_DIR}/#{self.ctl_name}.output"
	end
	
	def log
		"#{LOG_DIR}/#{self.ctl_name.chomp("_ctl")}.log"		
	end
	
	memoize :pid, :mem
	
	
	private	
	def tail_log(file,lines)
		execute("tail -n #{lines} #{File.expand_path(file)}")		
	end
end
