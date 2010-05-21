module Auto::JobModule
	STATE_WAITING = "waiting"
	STATE_RUNNING = "running"
	STATE_CANCELED = "canceled"
	STATE_DONE = "done"
  CATEGORY ="category_"
  DONE=" state = 'done' "
  
  
	
	STATES = {STATE_WAITING => "排队中",
    STATE_RUNNING => "执行中",
    STATE_DONE => "已完毕",
    STATE_CANCELED => "已取消"}.with_indifferent_access
    
  def after_initialize
    if new_record?
      self.state||= STATE_WAITING
    end
  end    
  

  def set_state!(state)
    self.state = state
    self.save!
   	if self.respond_to? :father
      if self.father
      	self.father.sync_progress 
      	self.father.save!
      end
    end
  end
  
  def state=(new_state)
  	new_state = new_state.to_s
    assert STATES.keys.include? new_state
    return if self.state == new_state    
    super new_state
    if [STATE_DONE , STATE_CANCELED].include?(new_state)
      on_job_done
    elsif new_state == STATE_RUNNING
      on_job_started
  	end

  end
	
  def on_job_started
  	self.started_at ||= Time.now
  end
  
  def on_job_done
  	self.done_at = Time.now 
  end
  
	def duration
		if self.done_at
			(self.done_at - self.started_at).ceil
    else
      0
		end
  end	
  
  
  module JobChild
    def on_job_started
    	super
	  end
  
	  def on_job_done
	  	super
	  end
	  

    def sibling_next
    	self.class.find(:first, :conditions => ["#{job_father_fk} = ? and id > ?", self.send(job_father_fk), self.id], :order=>"id")
    end
		
    def job_father_fk
    	assert false
    end
    
	end
	
	module JobFather
		
		# def cancel_all!
		# 	children.find(:all, :conditions=>{:state => [STATE_RUNNING, STATE_WAITING]}).each { |e| e.set_state!(STATE_CANCELED) }
		# end

    def sync_progress
      stats = children.all(:select=>"count(*) as count, state", :group=>"state").build_hash{|e|[e.state, e.count.to_i]}
      
      all_count = stats.sum{|e|e.last} 
      self.progress = (100*(stats["done"].to_i))/all_count
      if progress == 100
        self.set_state! STATE_DONE
      else
        if stats['running']
          self.set_state! STATE_RUNNING
        else
          self.set_state! STATE_WAITING
        end
      end
    end
	end
end
