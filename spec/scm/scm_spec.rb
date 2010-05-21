$:.unshift "lib/scm"
$:.unshift "lib"
module Scm
end
puts $:.first
require 'sync'
require 'data_excel.rb'

include Scm
describe DataExcel do
	it "should return valid data_result" do
	  data = DataExcel.new(File.dirname(__FILE__)+"/data_excel.xls").data_result
	  data[:ids].should eql([20272, 20273, 20274, 20277, 20278, 20279, 20288, 20289, 20293, 20294])
	  data[:titles].should eql(%w(是否执行	执行次数	备注	用户名	密码	点击对象	新增应用点名称	新增应用点标志	加密密钥	备注内容	校验点))
	  a = %w(kfctest01	taobao	应用点	云梦06	yunmenghello	K L M)	  
	  data[:datas].last.should eql(["N", "1", nil]+a)
	end
	
	
	it "should return valid data_result" do
	  data = DataExcel.new(File.dirname(__FILE__)+"/data_excel2.xls").data_result
	  data[:ids].should eql([145])
	end
	
	it "should return valid data_result" do
	  data = DataExcel.new(File.dirname(__FILE__)+"/data_excel3.xls").data_result
	  data[:ids].should eql([2478,2480,2482,2484])
	end
	
end
	