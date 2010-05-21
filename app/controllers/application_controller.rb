# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  #protect_from_forgery # See ActionController::RequestForgeryProtection for details
  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password           
  layout :tam_layout
  
  include ExceptionNotifiable
  include Auto
  include Base
  before_filter :set_current_user
  before_filter do |controller|
    user = User.current ? User.current.nickname : ''
    params = controller.params
    params.each do |k,v|
      params.delete(k) if v.instance_of?(Class)
    end
    VisitHistory.create :controller=>controller.class.to_s, :action=>controller.action_name,
      :params=>params, :user_name=>user
	  end if RAILS_ENV == 'production' # ֻ���������Ч
  
  def set_content_type(format)
  	response.content_type = Mime::Type.lookup_by_extension(format.to_s).to_s
	end
	
	def tam_layout
    if request.xhr?
      'ajax'
    else
      "application"
    end
  end

  private
  def set_current_user  	
  	user = if(login=request.env["HTTP_LOGIN_USER"] )
  		login = login.sub(/^taobao-hz\\/, "").gsub("(null),","").strip  		
  		assert !(login =~/ |\(|\)|,/)
	  	User.find_or_initialize_by_login(login)
		else
			User.first
		end
	  
  	if user && user.new_record?
  		user.attach_ldap!
  		user.save!
  	end
  	User.current = user || User.new(:login=>'guest',:nickname=>'guest')
  end
  
end
