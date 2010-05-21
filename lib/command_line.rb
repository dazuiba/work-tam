module CommandLine
 CommandFailed = Class.new(RuntimeError)
 def execute(cmd, options={})
  	__log(cmd)
  	safe_chdir(options[:chdir]) do
    begin
    	pwd = Dir.pwd
      result = `#{cmd}`
      result && result.chomp
    rescue Errno::ENOENT => e      
     	__log("CommandFailed: #{e.message}")
      raise CommandFailed.new(msg)
    end
  end
 end  
 
 def safe_chdir(dir,&block)
 	if dir.nil?
 		yield 
 	else
 		pwd = Dir.pwd
 		begin
 			Dir.chdir(dir)
 			yield
 		ensure
 			Dir.chdir(pwd)
 		end
 	end
 end
 
 private
 
 def __log(msg)
 	lg = (defined?(logger) ? logger : RAILS_DEFAULT_LOGGER)
 	lg && lg.info(msg)
 end
end
