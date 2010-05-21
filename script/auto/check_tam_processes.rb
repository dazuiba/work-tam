require 'open-uri'

base_url = "http://twork.taobao.net:3003"
hash_array = [
  {:ctl_name => "auto_bgjobexe_ctl", :request_path => "/admin/daemons/do_action/25?go=start"},
  {:ctl_name => "auto_bgjob_plan_exe_ctl", :request_path => "/admin/daemons/do_action/26?go=start"},
  {:ctl_name => "auto_svn_sync_ctl", :request_path => "/admin/daemons/do_action/27?go=start"},
  {:ctl_name => "auto_machines_ping_ctl", :request_path => "/admin/daemons/do_action/28?go=start"},
  {:ctl_name => "master_ctl", :request_path => "/admin/daemons/do_action/23?go=start"}
]
0.upto(hash_array.size-1) do |i|
  ctl_name = hash_array[i][:ctl_name]
  request_url = base_url + hash_array[i][:request_path]
  exec_result = system("ps auxw | grep -v grep | awk '{print $2, $11}' | grep #{ctl_name}")
  if exec_result
    p "#{ctl_name} is running."
  else
    begin
      p "try to start #{ctl_name}..."
      open(request_url)
      p "#{ctl_name} is running."
    rescue
      p "request failed: #{request_url}"
    end
  end
end
