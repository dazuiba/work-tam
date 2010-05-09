require "acts/active_record/list"
require "acts/active_record/typed_serialize"
require "acts/active_record/tree"
require "acts/controller/live_tree"   
require "extensions/all"

ActiveRecord::Base.extend Acts::ActiveRecord::List  
ActiveRecord::Base.extend Acts::ActiveRecord::Tree
ActionController::Base.extend Acts::Controller::LiveTree
