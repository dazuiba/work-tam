class Base::Product < ActiveRecord::Base
  belongs_to :product_line, :class_name => "Base::ProductLine"
  validates_presence_of :name
  validates_numericality_of :position
  validates_uniqueness_of :name, :scope=>["product_line_id"]
  has_many :projects  
  has_many :mind_maps, :class_name => "Map::MindMap"
  
  def self.next_position(line_id)
  	assert line_id
  	max_position = self.find(:first,:select=>"position", :conditions => ["product_line_id=?", line_id], :order=>"position desc")
  	next_position = max_position.nil? ? 0 : max_position.position.to_i+1
  	next_position
  end
  
  #
  #删除提示
  #return msg.  如果为blank表示可以删除.
  #
  def donot_del_msg(join_str="\n")
  	msg = []
  	if(count = mind_maps.count) > 0
  		msg << "关联 #{count}个MM图"
  	end
  	
  	if(count = projects.count) > 0
  		msg << "关联 #{count}个项目"
  	end
  	
  	msg.join(join_str)
  end
  
  def next_position
  	self.class.next_position(self.product_line_id)
  end
end
Product = Base::Product
