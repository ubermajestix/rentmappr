ActionController::Routing::Routes.draw do |map|
  map.resources :map_areas

  map.resources :users
  map.resource :session
  map.resource :map_areas
  
  map.signup          '/signup',          :controller => 'users',       :action => 'new'
  map.login           '/login',           :controller => 'sessions',    :action => 'new'
  map.logout          '/logout',          :controller => 'sessions',    :action => 'destroy'
  map.bug_report      '/bug_report',      :controller => "houses",      :action => "bug_report"
  map.file_bug_report '/file_bug_report', :controller => "houses",      :action => "file_bug"
  map.scrape          '/scrape/:id',      :controller => "map_areas",   :action => "scrape"
  map.choose_city     '/choose_city',     :controller => "houses",      :action => "choose_area"
  map.s               '/s',                :controller => "map_areas",   :action => "st"  
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
   map.clear_search '/clear', :controller=>"houses", :action=>"clear_search"
   map.landing '/landing', :controller=>"houses", :action=>"rickroll"
  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
