# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
	
	def jquery_script(options={}, &block)
		content = capture(&block)	
		concat(%[
		<script type="text/javascript" charset="utf-8">  
			    jQuery(document).ready(function($) {
						#{content}  		  
		  		});
		</script>], block.binding) 
	end
	
	def link_to_long_title(title, url={}, options={})
		if options[:popup]
			link_to_popup truncate(title,options[:length]||32), url, :title => title
		else
			link_to truncate(title,options[:length]||32), url, :title => title
		end
	end  
	
	
	def link_to_popup(name,options = {}, html_options = {})
    html_options.merge!(:rel=>"facebox")
		link_to name, options, html_options
	end
  
	def link_to_wangwang(user, options={})
      if user.is_a? User
        user = user.nickname
      end
      options.reverse_merge! :image=>true
      text = if options[:image]
        %[<img border='0' src='http://amos1.taobao.com/online.ww?v=2&uid=#{user}&site=cntaobao&s=1&charset=utf-8' alt=''/>]
      else
        user
      end   
      %[<a target='_blank' href='http://amos1.taobao.com/msg.ww?v=2&uid=#{user}&s=1&charset=utf-8'>#{text}</a>]
    end
  
end
