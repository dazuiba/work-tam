require 'platform/platform'
class TworkMailer < ActionMailer::Base	
  default_url_options[:host] = 'twork.taobao.net'
  FROM = "taobao-twork@taobao.com"
  add_template_helper ApplicationHelper
  add_template_helper RedmineHelper
  add_template_helper AutoHelper
  include Platform
  ##
  # 回归报告
  ##
  def category_report(bgjob_category, mail_to)  	
    recipients mail_to
    reports = Report.regress_reports
    preview_release_reports = Report.preview_release_reports
    
    subject    "[Twork]TAM和平台回归报告 week[#{bgjob_category.title}] "
    from       FROM
    body ("bgjob_category" => bgjob_category, "reports" =>reports,"preview_release_reports" =>preview_release_reports,
          "bgjob_category_rs"=>bgjob_category.result,"reports_rs"=>Report.result(reports),
          "preview_release_reports_rs"=>Report.result(preview_release_reports))
    content_type "text/html"
  end
  ##
  #测试集确认报告
  ##
  def bgjob_suite_confirm(bgjob_suite, mail_to_users, bgjob_category)
    line = bgjob_suite.testsuite.project.product_line
    
    recipient_users mail_to_users
    
    subject    "[Twork]T-AutoMan回归, 请尽快完成#{line.name}线的回归确认"
    from       FROM
    body "bgjob_suite" => bgjob_suite
    content_type "text/html"
  end
  
  # Renders a message with the corresponding layout
  def render_message(method_name, body)
    mail_layout = 'layout.html.erb'
    body[:content_for_layout] = render(:file => method_name, :body => body)
    ActionView::Base.new(template_root, body, self).render(:file => "twork_mailer/#{mail_layout}", :use_full_path => true)
  end
  
  private
  
  def recipient_users(users)
    recipients users.map(&:email)
  end
end