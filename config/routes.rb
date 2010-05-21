ActionController::Routing::Routes.draw do |map|
  #map.root :controller => 'pm_libs'

  map.resources :pm_libs do |lib|
    lib.resources :pm_folders
  end                         
  map.resources :pm_folders, :collection=>["folder_live_tree_data"]
  map.resources :pm_models do |model|
    model.resources :pm_elements
  end                                       
  
  map.resources :pm_elements, :collection=>["element_live_tree_data"]
  
  map.namespace :auto do|auto|
		auto.resources :testsuites, :collection => {:pick_down=>[:post],:pick_up=>[:get,:post],:pick_up_do=>[:post],:testplan => [:get, :post],:cancel => :get,:list_by_machine => [:get,:post]}, :member => {:editplan => :get,:updateplan => :put} do |suite|
			suite.resources :bgjob_suites
		end
		auto.resources :testcase_scripts, :bgjob_suites
		auto.resources :testcases, :member => [:show_testcase], :collection => [:search]
    auto.resources :home, :collection => [:main, :index, :frame_left, :frame_mid, :tree, :tree_left, :gen_tree, :console]
		auto.resources :bgjobs, :member=>[:log, :job_done, :create_job], :collection => [:get_job]
  	auto.resources :testcase_categories, :member=>[:testcases, :testcase_list], :collection => { :tree => [:get,:post] }
  end
  
  map.namespace :admin do|admin|
		admin.resources :jobs
		admin.resources :daemons, :collection=>{:sync_all=>[:get, :post]}
		admin.resources :products
    admin.resources :product_lines, :has_many => :products
    admin.resources :testsuites_categories,:collection => {:list => [:get,:post],:report =>[:get,:post],:testplan => :get,:make_plan => [:get,:post]}
	end
	
	map.connect 'projects/:project_id/testsuites/:action', :controller => 'auto/testsuites'

	map.connect 'home/modules.js', :controller=>"home", :action => "modules"
  map.root :controller => "home", :action => "frame", :m => "auto"

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
