module ReportHelper
  def google_chart_dist(method_stat)
    dists = method_stat.dist
    counts = dists.map(&:count)
    #labels = dists.map{|e| "#{e.dist_start} ~ #{e.dist_end}(#{e.count})" }
    #labels = [dists.map(&:dist_end), 0, counts.sum].join("|")
    labels = [[dists.map(&:dist_end)], [0, counts.sum]]
    
    #Gchart.pie_3d(:title => 'avg response time:'+method_stat.avg_time.to_s+'ms', :size => '500x200',
    #         :data => counts, :labels => labels)              
    Gchart.bar(:title => 'average response time:'+method_stat.avg_time.to_s+'ms', :data => counts, :max_value => counts.sum,
    				 :encoding => 'extended', :size => '360x200', :axis_with_labels => 'x,y', :axis_labels => labels, :bar_width_and_spacing => '25,6')
    
  end
  
  def google_chart_levels(level_index)
    #level_count = @request_stat.method_stats.map { |m| m.levels[level_index]}
    level_count = Hash.new
    @request_stat.method_stats.each_with_index { |m, index| level_count[index+1] = m.levels[level_index]}
    level_count.delete_if{|k ,v| v == 0 }
    Gchart.pie_3d(:title => 'level:'+"#{level_index+1}", :size => '360x200',
             :data => level_count.values, :labels => level_count.keys)          
    
  end
  
  def rank_list(rank_index)
    rank_list = Hash.new
    @request_stat.method_stats.each_with_index do|method_stat, i|
    if method_stat.levels[rank_index] > 0
      rank_list[i] = method_stat.levels[rank_index]
    end
  end
  rank = rank_list.sort { |a, b | a[1] <=> b[1] }
  rank.reverse!
end

  def product_line_bar_testcase_count(data)
    require 'set'
    set = Set.new data.values
    Gchart.bar(:title => '各产品线的自动化用例统计',:data => data.values.reverse,:size => '300x400', 
             :orientation => 'horizontal',:axis_with_labels => ['x','y'],:axis_labels =>[set.to_a.sort,data.keys],
             :bar_width_and_spacing => '10,3',:stacked => false)
  end
  def product_line_pie_testcase_count(data)
    Gchart.pie_3d(:size => '400x200', :data => data.values,:labels => data.keys,:title => '各产品线的自动化用例统计',:stacked => false)
  end
  
  def auto_bgjob_suites_action_report(data,title)
    Gchart.pie_3d(:size => '400x200', :data => data.values,:labels => data.keys,:title => title,:stacked => false)
  end
  
  def failed_reason_report data
      Gchart.bar(:title => '全网回归自动化用例出错原因统计',:data => data.values.reverse,:size => '600x300', 
             :orientation => 'horizontal',:axis_with_labels => ['x','y'],:axis_labels =>[data.values.sort,data.keys],
             :bar_width_and_spacing => '30,10',:stacked => false)
  end
  
end
