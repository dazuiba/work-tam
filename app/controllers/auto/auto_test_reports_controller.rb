class Auto::AutoTestReportsController < ApplicationController
  include Auto
  include CommonUtils
  helper :report
  before_filter :set_time, :only=>[:failed_reason_report, :bug_report,:regress_exec_result_report]
  def index
    puts Time.now
    @arr_auto_overview = Auto::AutoTestReport.product_line_overview
    puts Time.now
  end
  
  def detail
    @auto_state=params[:auto_state]
    @id=params[:id]
    product_line = Base::ProductLine.find(@id)
    @testcases = product_line.detail_testcases @auto_state,params[:page]
  end
  
  def testcase_history
    @testcase_id = params[:id]
    @auto_bgjobs=Auto::AutoBgjob.find(:all,:conditions => 
        ["#{Auto::JobModule::DONE} and testcase_id=?",params[:id]],
      :order => "id desc").paginate(:page => params[:page], :per_page => 25)
  end
  
  def failed_reason_report
    
    @reason_report=Auto::AutoTestReport.failed_reason_report @year,@month
  end
  def failed_reason_detail
    @year = params[:year]
    @month = params[:month]
    @reason_info = params[:reason_info]
    @auto_bgjobs = Auto::AutoTestReport.failed_reason_detail @year,@month,@reason_info,params[:page]
  end
  
  def bug_report
    @auto_bgjobs = Auto::AutoTestReport.bug_report @year,@month,params[:page],@product_line,@designer
  end
  def regress_exec_result_report
    @auto_bgjobs = Auto::AutoTestReport.regress_exec_result_report @year,@month,params[:page],@product_line,@designer,@priority
  end
  
  private 
  
  def set_time
    @year = params[:year]
    @month = params[:month]
    @year = DateTime.now.year if @year.nil?
    @month = DateTime.now.month if @month.nil?
    @product_line = params[:product_line]
    @designer = params[:designer]
    @priority = params[:priority]
    @tab = params[:tab]
  end
  
end
