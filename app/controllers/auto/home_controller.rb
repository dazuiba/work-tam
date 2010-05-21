class Auto::HomeController < ApplicationController    
	layout false
	def index
	 	redirect_to "/home/frame?m=auto"
	end
                              
  def main                
    @product_lines = ProductLine.all(:conditions=>{:name=>%w[商品 交易 服务 商家平台 无线 收费 营销 店铺 淘江湖 社区 招商 开放平台]})
    @log_board = AutoRedmine::Board.find_board(:LOG)
    @sug_board = AutoRedmine::Board.find_board(:SUG)
    @jobs_map = @product_lines.build_hash{|line|
    	jobs = Auto::AutoBgjob.all( 
        :select => "auto_bgjobs.exec_user_id, auto_bgjobs.testcase_id, \
                    auto_bgjobs.exec_result, auto_bgjobs.exec_ip, auto_bgjobs.started_at, \
                    auto_bgjobs.state, auto_bgjobs.id",
        :joins => "INNER JOIN testcases ON testcases.id = testcase_id LEFT JOIN \
                 projects on testcases.project_id = projects.id",
        :conditions => ["projects.line_id = ? ", line.id],
        :order => "auto_bgjobs.id desc",
        :limit => 15)
    	[line.id, jobs]
  	}
  	render :layout=>false
  end
   
  def feedback 
    return if request.get?
                                    
    board = AutoRedmine::Board.find_board(:SUG)
    if params[:subject].to_s.empty?
      flash[:message]  = "请正确填写参数！"
    else
      board.create_message(User.current, :subject=>params[:subject], :content => params[:content])
      flash[:message] = "谢谢您的建议，我们会及时反馈！"
    end
    redirect_to :back
  end
   
  def index
  end

  def gen_tree
    str = ""
    parent_id = params[:parent_id].to_i
    if parent_id > 0
      str = "["
      tcs = Auto::TestcaseCategory.find_all_by_parent_id(parent_id, :select => "id, parent_id, position, title")
      if tcs.size > 0
        for i in 0..tcs.size-1 do
          tc = tcs[i]
          str += "{ attributes : { \"id\" : \"#{tc.id}\", href : \"/auto/testcase_categories/#{tc.id}/testcase_list\", flag:\"#{tc.category_leaf?}\" }, data : #{tc.text.to_json}, state : \"closed\" }"
          if i < tcs.size-1
            str += ","
          end
        end
      else
        ts = Auto::Testcase.find(:all, :select => "id, title, position", :conditions => ["category_id = ?", parent_id])
        for j in 0..ts.size-1 do
          t = ts[j]
          str += "{ attributes : { \"id\" : \"#{t.id}\", href : \"/auto/testcases/#{t.id}/show_testcase\"  }, data : { title: #{t.text.to_json}, icon : \"/automan/jstree/themes/default/leaf.gif\" }}"
          if j < ts.size-1
            str += ","
          end
        end
      end
      str += "]"
    end
    render :json => str
  end

  def console
    console_name = params[:name]
    id = params[:id]
    prefix = params[:prefix]
    if console_name == "gen_dir"
      node = Auto::TestcaseCategory.find(id, :select => ["id, parent_id, title"])
      root_dir = get_root_node(node)
      file_dir = "#{RAILS_ROOT}/public/automan/autotest/#{root_dir}"
      Dir.mkdir(file_dir) if !File.exists? file_dir
      console = `cd #{file_dir} && rm -rf #{prefix}_* && ruby /var/www/tcommon-0.3/lib/bin/gen_dir #{prefix}`
      if console == ""
        render :text => console
      else
        render :text => "root_node:"+root_dir+"\n"+console
      end
    else
    end
  end

  private
  def get_root_node(node)
    if node.parent_id.nil?
      return node.title.split("_")[0]
    else
      n = Auto::TestcaseCategory.find(:first,
        :conditions => ["id = ?", node.parent_id], :select => "id, parent_id, title")
      get_root_node(n)
    end
  end
end
