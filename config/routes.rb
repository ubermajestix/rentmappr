ActionController::Routing::Routes.draw do |map|
  map.resources :users
  map.resource :session
  map.resources :map_areas
  
  map.signup          '/signup',          :controller => 'users',       :action => 'new'
  map.login           '/login',           :controller => 'sessions',    :action => 'new'
  map.logout          '/logout',          :controller => 'sessions',    :action => 'destroy'
  map.bug_report      '/bug_report',      :controller => "houses",      :action => "bug_report"
  map.add_city        '/add_city',        :controller => "houses",      :action => "bug_report", :city=>true
  map.file_bug_report '/file_bug_report', :controller => "houses",      :action => "file_bug"
  map.scrape          '/scrape/:id',      :controller => "map_areas",   :action => "scrape"
  map.choose_city     '/choose_city',     :controller => "houses",      :action => "choose_area"
  map.pick_area       '/pick_area',       :controller => "houses",      :action => "pick_area"
  map.s '/s',:controller => "map_areas",   :action => "st"
  map.s_all               '/s/all/:last_12/:areas/:week',               :controller => "map_areas",   :action => "st", :defaults=>{:last_12=>true, :areas=>true, :week=>true}
  map.s_day           '/s/day/:last_12',  :controller => "map_areas",   :action => "st", :defaults=>{:last_12=>true}
  map.s_areas           '/s/areas/:areas',  :controller => "map_areas",   :action => "st", :defaults=>{:areas=>true}
  map.s_week          '/s/week/:week',  :controller => "map_areas",   :action => "st", :defaults=>{:week=>true}
  
  map.edit_area '/map_areas/edit/:id', :controller=>"map_areas", :action=>"edit"

  map.list_houses '/list/:id', :controller => "houses", :action => "list"
  map.search_list '/list_search', :controller => "houses", :action => "search_list"
   map.confirm        '/reset_password/:reset_code',                    :controller => 'users',  :action => 'reset_password'
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

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
   map.root :controller => "houses"
   map.search  '/search', :controller=>"houses", :action=>"index", :search=>true
   
   map.restful_search  '/search/:min_price/:max_price/:bedrooms/:dogs/:cats', :controller=>"houses", :action=>"index", :search=>true
   map.restful_search_no_pets  '/search/:min_price/:max_price/:bedrooms', :controller=>"houses", :action=>"index", :search=>true
   map.restful_search_dogs '/search/:min_price/:max_price/:bedrooms/:pets', :controller=>"houses", :action=>"index", :search=>true
 #  map.search  '/search/:min_price/:max_price', :controller=>"houses", :action=>"index", :search=>true
   map.clear_search '/clear', :controller=>"houses", :action=>"index"
   map.landing '/landing', :controller=>"houses", :action=>"rickroll"
  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
