require 'rubygems'
require 'daemons'
require File.dirname(__FILE__) + "/daemon_extension"
require 'active_support'

options = YAML.load(File.read(File.dirname(__FILE__) + "/daemons.yml")).with_indifferent_access
puts options["app_name"] = File.basename($0)
Daemons.run File.join(File.dirname(__FILE__),FILE_NAME) , options