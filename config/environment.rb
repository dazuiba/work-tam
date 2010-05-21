# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.5' unless defined? RAILS_GEM_VERSION

require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  config.gem "daemons"
  config.gem "googlecharts", :lib => "gchart"
  config.load_paths << "#{RAILS_ROOT}/app/models/base/"
  config.load_paths += Dir["#{RAILS_ROOT}/vendor/gems/**"].map do |dir|
    File.directory?(lib = "#{dir}/lib") ? lib : dir
  end

  config.action_mailer.default_url_options = { :host => 'twork.taobao.net'}
  
  config.time_zone = 'Beijing'             
  config.active_record.default_timezone = :local
  
end

ExceptionNotifier.exception_recipients = %w(baoju@taobao.com yangchen@taobao.com zhushi@taobao.com nanfei@taobao.com yunmeng@taobao.com taichan@taobao.com)
ExceptionNotifier.sender_address = %("AutoMan Application Error" <twork@taobao.com>)

ActionMailer::Base.smtp_settings = {
  :address => 'twork.taobao.net',
  :port => 25
}

WillPaginate::ViewHelpers.pagination_options[:prev_label] = '上一页'
WillPaginate::ViewHelpers.pagination_options[:next_label] = '下一页'