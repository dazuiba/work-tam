class Auto::TestsuitesTestcase < ActiveRecord::Base
	belongs_to :testsuite
	belongs_to :testcase
end
