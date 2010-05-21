class Machine < ActiveRecord::Base
  extend ActiveSupport::Memoizable
  RUNNING_TIMEOUT = 10 #分钟
  GEM_PACKAGE_UPGRADE = "C:/gem_package_upgrade.bat"
  HOST_ADD = "C:/WINDOWS/system32/drivers/etc/hosts"
  GEM_LIST ="gem list "
  TYPE = {:auto => 1, :perf=>10, :other => nil}
  TYPE_TXT = {:auto => "TAM", :perf => "性能专用", :other => "其他"}
  TYPE_SELECT_PARE = [ ["TAM",1], ["性能专用",10], ["其他",nil] ]
  
  PING_OK = {:ping_ok=>1}
  
  #validates_format_of :ip, :with => /^(\d{1,3}\.){3}\d{1,3}$/  
	validates_presence_of :name, :ip
  named_scope :auto, :conditions=>"machine_type = #{TYPE[:auto]}"
  named_scope :auto_virtual, :conditions=>"machine_type = #{TYPE[:auto]} AND is_virtual = 1"
  named_scope :publics, :conditions=>"auto_user_id is null"
  named_scope :locked, :conditions=>"locked_by_id is null"
  named_scope :ping, :conditions=>"ping_ok = #{PING_OK[:ping_ok]}"
	
  #自动化专用字段
  belongs_to :auto_user, :class_name => "User"
	belongs_to :locked_by, :class_name => "Auto::AutoBgjob"  
    

  def self.paginate_by_type(type, options={})
  	sql = if(t = TYPE[type])
  		str = "machine_type = #{t}"
  		str<< " and auto_user_id is null" if type ==:auto
  		str
  	elsif(type == :auto_self)
  		#自动化机器
  		"auto_user_id is not null "
		elsif(type == :other)
			"machine_type is null"
		else
			assert false, "#{type} should be in #{TYPE.inspect}"
		end	
		
		if q = options[:q]
			field, value = q.split("=")
			sql<<"and #{field} like '#{value}'"
		end
		options.reverse_merge!(:page=>1)
		self.paginate({:conditions => sql}.merge(options.slice(:page,:per_page,:order)))
  end
  
  def self.find_or_create_private(user, ip)
    assert user
    if machine = self.find_by_auto_user_id(user.id)     
      machine.ip = ip
      machine.save!
      machine
    else
      Machine.create!(:auto_user => user, :ip=>ip, :machine_type => 1, :name=>"#{user.nickname}的机器")
    end
  end
  
  def self.auto_avaliables
    auto.scoped_by_ping_ok(true).scoped_by_locked_by_id(nil)
  end
  
  def self.release!(ip, _locked_by)
    machine = find_by_ip(ip)
    #assert(_locked_by == machine.locked_by)
    machine.update_attributes!(:locked_by => nil)
  end
  
  def self.lock!(ip, obj)
    machine = find_by_ip(ip)    
    machine.update_attributes!(:locked_by => obj)
  end
  
  def type_sym
  	return :auto_self if auto_user_id
  	TYPE.invert[self.machine_type]||:other
  end
  
  def machine_type_text
  	TYPE_TXT[type_sym]
  end
  
  def self.select_able
    Machine.auto.publics.select{|e|e.ping_ok ==1 && e.locked_by_id.nil?}
  end
  
  def self.select_unable
    Machine.auto.publics.select{|e|!(e.ping_ok ==1 && e.locked_by_id.nil?)}
  end
  
  def self.order_unable_able
    select_unable.nil? ? select_able : select_unable+select_able
  end
  
  def self.order_able_unable
    select_able.nil? ? select_unable : select_able+select_unable
  end
  
  def self.gem_upgrade_bat arr_exec_ip,cmd
    exec_info_hash=Hash.new
    arr_exec_ip.each{|exec_ip|
      exec_info_hash[exec_ip]=gem_upgrade exec_ip,cmd
    }
    return exec_info_hash
  end
  
  def self.gem_upgrade exec_ip,cmd
    cmd_line = "STAF #{exec_ip} PROCESS START SHELL COMMAND '#{cmd}' FOCUS Minimized RETURNSTDOUT STDERRTOSTDOUT WAIT"
    puts cmd_line
    `#{cmd_line}`
  end


  def self.copy_gem_cmd (target,exec_ip)
    cmd_line = "staf local fs copy FILE #{target} TOFILE #{GEM_PACKAGE_UPGRADE} TOMACHINE #{exec_ip} "
    system(cmd_line)
  end
  
  def self.copy_gem_cmd_bat (target,arr_exec_ip)
    arr_exec_ip.each{|exec_ip|
      copy_gem_cmd target, exec_ip
    }
  end
  
  def  gem_list 
    cmd_line="STAF #{ip} PROCESS START SHELL COMMAND '#{GEM_LIST}' FOCUS Minimized RETURNSTDOUT STDERRTOSTDOUT WAIT"
    `#{cmd_line}`
  end

  def self.host_info ip
    cmd_line="STAF #{ip} FS GET FILE #{HOST_ADD} "
    `#{cmd_line}`
  end

  def self.host_info_update ip, info
    cmd_line = "staf #{ip}  PROCESS START SHELL COMMAND  echo  #{info} STDOUT #{HOST_ADD} WAIT RETURNSTDOUT STDERRTOSTDOUT"
    `#{cmd_line}`
  end

  def  self.tns_info ip, add
    cmd_line="STAF #{ip} FS GET FILE #{add} "
    `#{cmd_line}`
  end

  def self.tns_info_update ip,info,tns_add
    cmd_line = "staf #{ip}  PROCESS START SHELL COMMAND  echo \-e  #{info} STDOUT  #{tns_add} "
    `#{cmd_line}`
  end

  #WAIT RETURNSTDOUT STDERRTOSTDOUT
  def avaliable?
    locked_by_id.nil? && ping_ok?(ip)
  end
  
  def sync_state(logger=self.logger)
    self.ping_ok = __ping_ok?(logger)
    if locked_by
      if locked_by.started_at < RUNNING_TIMEOUT.minutes.ago
        locked_by.exec_result = Auto::AutoBgjob::RESULT_RUNNING_TIMEOUT
        locked_by.set_state!(Auto::AutoBgjob::STATE_DONE)
        #解除Lock
        self.locked_by_id = nil
      end
    end
    self.save!
  end
  
  def self.kill_ruby_process exec_ip, cmd='taskkill /F /IM ruby.exe'
    cmd_line = "STAF #{exec_ip} PROCESS START SHELL COMMAND #{cmd} FOCUS Minimized RETURNSTDOUT STDERRTOSTDOUT WAIT"
    puts cmd_line
    `#{cmd_line}`
  end
  
  private  
  def __ping_ok?(logger=self.logger)
    result = true
    time = Benchmark.realtime {
      output = `STAF #{ip} PING PING`
      output_list = output.split("\n")
      result = (output_list[2] == 'PONG')
    }
    logger.info "Ping #{ip} result ok? : #{result}, #{Utils.fmt_float(time)} used. Locked by : #{self.locked_by_id}"
    return result
  end
  
end
