#custom routes for this plugin
ActionController::Routing::Routes.draw do |map|
  
  map.resources :expenses,
                :collection => {:bulk_edit => [:get, :post], :bulk_update => :post, :bulk_destroy => :delete, :context_menu => :get}
  
  map.resources :projects do |project|
   project.resources :expenses, :only => [:index, :new, :create]              
  end
  
end