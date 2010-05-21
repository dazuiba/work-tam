module CommonUtils
  GEM_CMD_FILE="gem_package_upgrade.bat"
  DIR = "/public/download/"
  def create_gem_cmd_file (root,cmd)
    cmd_file=root +"#{DIR}#{GEM_CMD_FILE}"
    File.open(cmd_file,"w") do |file|
      file.puts cmd
    end
  end
  def add_arr arr1,arr2
      if arr1 && arr2
         return arr2 + arr1
      elsif arr1 && arr2.nil?
         return arr1
      elsif arr2 && arr1.nil?
         return arr2
      else
         return Array.new
      end
  end
  
  def quarter month
    case month
      when 1..3 then return 1
      when 4..6 then return 2
      when 7..9 then return 3
      when 10..12 then return 4
      end
  end
  
  def handle ip, remote_ip
    if ip=~/(.*)\(我的机器\)/
      Machine.find_or_create_private(User.current, $1)
      return request.remote_ip
    elsif ip=~/\(.*\)/
      start_index = ip=~/\(/
      start_index+=1
      end_index = ip=~/\)/
      return ip[start_index, end_index-start_index]
    else
       return ip
    end
  end
  
end