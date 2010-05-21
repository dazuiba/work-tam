require 'rubygems'
require File.dirname(__FILE__) + "/../../config/environment"

auto_bgjobs = Auto::AutoBgjob.find_all_by_script_path("test.rb")
for auto_bgjob in auto_bgjobs
  if auto_bgjob.testcase and auto_bgjob.testcase.script
    p auto_bgjob.id
    script_path = auto_bgjob.testcase.script.script_path
    auto_bgjob.script_path = script_path
    auto_bgjob.save
    p 'ok!'
  end
end