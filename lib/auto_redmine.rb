module  AutoRedmine
    class Board < ActiveRecord::Base 
       establish_connection(:redmine)   
       has_many :messages, :class_name => "AutoRedmine::Message" , :conditions => "parent_id IS NULL", :order=>" updated_on desc"       
       BOARDS = {:LOG=>3, :SUG=>4}     
       
       def self.find_board(sym)     
          raise sym.inspect if BOARDS[sym].nil?
          self.find(BOARDS.fetch sym)
       end       
       
       def create_message(twork_user, hash)    
         redmine_user = AutoRedmine::AutomanUser.auto_register(twork_user) 
         message = self.messages.build(hash)
         message.author = redmine_user 
         message.save!
       end
    end       
    
    class AutomanUser < ActiveRecord::Base
      establish_connection(:redmine)  
      set_table_name "users"
      validates_presence_of :login, :nickname, :mail      
 
      def self.auto_register(twork_user)     
        redmine = self.find_or_initialize_by_login(twork_user.login)
         if redmine.new_record? 
           redmine.attributes = twork_user.attributes.slice("nickname", "name").merge("auth_source_id"=>1)
           redmine.mail = twork_user.email                                                               
           redmine.type = "User"
           redmine.save!         
         end 
         redmine
      end   
       
      
      #overite
      protected
      def self.compute_type(_type)
        if _type == "User"
           AutoRedmine::AutomanUser
        else
          super
        end
      end
    end
  
    class Message < ActiveRecord::Base      
      establish_connection(:redmine)   
      belongs_to :author, :class_name => "AutoRedmine::AutomanUser"
      belongs_to :board, :class_name=>"AutoRedmine::Board"  
      validates_presence_of :board, :subject, :content, :author_id
      validates_length_of :subject, :maximum => 255
    end    
end     
