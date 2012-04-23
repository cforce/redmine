#custom routes for this plugin
ActionController::Routing::Routes.draw do |map|
  
  map.resources :invoices,
                :collection => {:bulk_edit => [:get, :post], :bulk_update => :post, :bulk_destroy => :delete, :context_menu => :get}
  
  map.resources :projects do |project|
   project.resources :invoices, :only => [:index, :new, :create]              
  end
  
  # map.with_options :controller => 'invoices' do |invoices_routes|
  #   invoices_routes.connect "invoices", :conditions => { :method => :get }, :action => 'index' #post for live search   
  #   invoices_routes.connect "invoices.:format", :conditions => { :method => :get }, :action => 'index'   
  #   invoices_routes.connect "invoices.:format", :conditions => { :method => :post }, :action => 'create'   
  #   invoices_routes.connect "invoices/:id", :conditions => { :method => :get }, :action => 'show', :id => /\d+/
  #   invoices_routes.connect "invoices/:id.:format", :conditions => { :method => :get }, :action => 'show', :id => /\d+/
  #   invoices_routes.connect "invoices/:id.:format", :conditions => { :method => :put }, :action => 'update', :id => /\d+/
  #   invoices_routes.connect "invoices/:id", :conditions => { :method => :put }, :action => 'update', :id => /\d+/
  #   invoices_routes.connect "invoices/:id/edit", :conditions => { :method => :get }, :action => 'edit', :id => /\d+/
  #   invoices_routes.connect "invoices/:id", :conditions => { :method => :delete }, :action => 'destroy', :id => /\d+/  
  #   invoices_routes.connect "projects/:project_id/invoices", :conditions => { :method => [:get, :post] }, :action => 'index' #post for live search   
  #   invoices_routes.connect "projects/:project_id/invoices.:format", :conditions => { :method => :get }, :action => 'index'
  #   invoices_routes.connect "projects/:project_id/invoices.:format", :conditions => { :method => :post }, :action => 'create'
  #   invoices_routes.connect "projects/:project_id/invoices/create", :conditions => { :method => :post }, :action => 'create'
  #   invoices_routes.connect "projects/:project_id/invoices/new", :conditions => { :method => [:get, :post] }, :action => 'new'
  #   invoices_routes.connect "projects/:project_id/invoices/:id", :conditions => { :method => :get }, :action => 'show', :id => /\d+/
  #   invoices_routes.connect "projects/:project_id/invoices/:id.:format", :conditions => { :method => :get }, :action => 'show', :id => /\d+/
  #   invoices_routes.connect "projects/:project_id/invoices/:id/update", :conditions => { :method => :put }, :action => 'update', :id => /\d+/  
  #   invoices_routes.connect "projects/:project_id/invoices/:id/edit", :conditions => { :method => :get }, :action => 'edit', :id => /\d+/  
  #   invoices_routes.connect "projects/:project_id/invoices/:id", :conditions => { :method => :delete }, :action => 'destroy', :id => /\d+/  
  #   invoices_routes.connect "projects/:project_id/invoices/notes", :conditions => { :method => [:get, :post]}, :action => 'invoices_notes'
  #   invoices_routes.connect "invoices/bulk_destroy", :action => "bulk_destroy"
  #   invoices_routes.connect "invoices/bulk_edit", :action => "bulk_edit"
  #   invoices_routes.connect "invoices/context_menu", :action => "context_menu"
  # end
  # 
  map.connect "invoices_time_entries/:action", :controller => "invoices_time_entries"
  
end