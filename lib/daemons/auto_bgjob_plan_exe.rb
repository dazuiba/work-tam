#!/usr/bin/env ruby
#title: 测试计划
#author: 柱石
require 'rubygems'
require File.dirname(__FILE__) + "/../../config/environment"
require File.dirname(__FILE__) + "/daemonable"
include CommandLine
Daemonable.every_hour(__FILE__) do |logger|
	plans = Auto::Testsuite.find_all_exec_plan
	logger.info "Start to Checking Plan, #{plans.size} gotten!"
	plans.each do |test_suite|
    suitejob = test_suite.bgjob_suites.build(:exec_ip=>test_suite.plan_ip)
    suitejob.exec_user_id = test_suite.created_by_id || 1
    suitejob.is_plan = true
    test_suite.exec_plan[:last_executed_at] = Time.now
    begin
    suitejob.save!
    logger.info "Exec Testsuite: #{test_suite.title}, 有效用例：#{test_suite.included_testcases_count}个"
    rescue 
      logger.info "Exec Testsuite: 创建测试集任务失败"
    end
  end

  regeress_plans = Auto::TestsuiteCategory.find_all_regress_plan
	logger.info "Start to Checking Regress Plan, #{regeress_plans.size} gotten!"
	regeress_plans.each do |test_suite_category|
    categery_job = test_suite_category.bgjob_categories.build(
      :exec_user_id => test_suite_category.exec_user_id,
      :state => Auto::JobModule::STATE_WAITING,
      :testsuite_category_id=>test_suite_category.id
    )
    categery_job.save!
    Auto::TestsuiteCategory.create_bgjob_suite(test_suite_category.testsuite_regress_ip[:arr_exec],test_suite_category.testsuite_regress_ip[:arr_exec_ip],categery_job)
    logger.info "Exec Testsuite: #{test_suite_category.title}, 包含测试集：#{regeress_plans.count}个"
  end
end

