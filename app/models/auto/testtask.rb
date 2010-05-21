class Auto::Testplan < ActiveRecord::Base
	has_and_belongs_to_many :testcases, :class_name => "Auto::Testcase"
	belongs_to :project
	belongs_to :created_by, :class_name => "User"
	validates_presence_of :title
	validates_presence_of :description
	validates_uniqueness_of :title
end