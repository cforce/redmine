#custom routes for this plugin
ActionController::Routing::Routes.draw do |map|
  
  # map.resources :contacts,
  #               :collection => {:bulk_edit => [:get, :post], 
  #                               :bulk_update => :post, 
  #                               :bulk_destroy => :delete, 
  #                               :context_menu => :get,
  #                               :preview_email => :get,
  #                               :edit_mails => :get,
  #                               :send_mails => :post,
  #                               :edit_tags => :post},
  #               :path_names => { :contacts_notes => 'notes'},
  #               :new => {:index => [:get, :post]}
  # 
  # map.resources :projects do |project|
  #   project.resources :contacts, 
  #                     :path_names => { :contacts_notes => 'notes'},
  #                     :collection => {:edit_tags => :post},
  #                     :new => {:index => [:get, :post]}
  # end
  # map.connect "contacts/notes", :conditions => { :method => [:get, :post] }, :controller => "contacts", :action => 'contacts_notes'

  map.with_options :controller => 'contacts' do |contacts_routes|
    contacts_routes.connect "contacts", :conditions => { :method => [:get, :post] }, :action => 'index' #post for live search   
    contacts_routes.connect "contacts.:format", :conditions => { :method => :get }, :action => 'index'   
    contacts_routes.connect "contacts.:format", :conditions => { :method => :post }, :action => 'create'   
    contacts_routes.connect "contacts/:id", :conditions => { :method => :get }, :action => 'show', :id => /\d+/
    contacts_routes.connect "contacts/:id.:format", :conditions => { :method => :get }, :action => 'show', :id => /\d+/
    contacts_routes.connect "contacts/:id.:format", :conditions => { :method => :put }, :action => 'update', :id => /\d+/
    contacts_routes.connect "contacts/:id", :conditions => { :method => :put }, :action => 'update', :id => /\d+/
    contacts_routes.connect "contacts/:id/edit", :conditions => { :method => :get }, :action => 'edit', :id => /\d+/
    contacts_routes.connect "contacts/notes", :conditions => { :method => [:get, :post] }, :action => 'contacts_notes'
    contacts_routes.connect "projects/:project_id/contacts", :conditions => { :method => [:get, :post] }, :action => 'index' #post for live search   
    contacts_routes.connect "projects/:project_id/contacts.:format", :conditions => { :method => :get }, :action => 'index'
    contacts_routes.connect "projects/:project_id/contacts.:format", :conditions => { :method => :post }, :action => 'create'
    contacts_routes.connect "projects/:project_id/contacts/create", :conditions => { :method => :post }, :action => 'create'
    contacts_routes.connect "projects/:project_id/contacts/new", :conditions => { :method => :get }, :action => 'new'
    contacts_routes.connect "projects/:project_id/contacts/:id", :conditions => { :method => :get }, :action => 'show', :id => /\d+/
    contacts_routes.connect "projects/:project_id/contacts/:id.:format", :conditions => { :method => :get }, :action => 'show', :id => /\d+/
    contacts_routes.connect "projects/:project_id/contacts/:id/update", :conditions => { :method => :put }, :action => 'update', :id => /\d+/  
    contacts_routes.connect "projects/:project_id/contacts/:id/edit", :conditions => { :method => :get }, :action => 'edit', :id => /\d+/  
    contacts_routes.connect "projects/:project_id/contacts/:id/destroy", :conditions => { :method => :delete }, :action => 'destroy', :id => /\d+/  
    contacts_routes.connect "projects/:project_id/contacts/notes", :conditions => { :method => [:get, :post]}, :action => 'contacts_notes'
    contacts_routes.connect "projects/:project_id/contacts/:id/edit_tags", :conditions => { :method => :post }, :action => 'edit_tags'
    contacts_routes.connect "contacts/context_menu", :action => "context_menu"
    contacts_routes.connect "contacts/preview_email", :action => "preview_email"
    contacts_routes.connect "contacts/bulk_update", :action => "bulk_update"
    contacts_routes.connect "contacts/bulk_edit", :action => "bulk_edit"
    contacts_routes.connect "contacts/edit_mails", :action => "edit_mails"
    contacts_routes.connect "contacts/send_mails", :action => "send_mails"
    contacts_routes.connect "contacts/bulk_destroy", :action => "bulk_destroy"
    contacts_routes.connect "contacts/edit_tags", :action => "edit_tags"
  end
  
  map.with_options :controller => 'contacts_tasks' do |contacts_issues_routes|  
    contacts_issues_routes.connect "projects/:project_id/contacts/tasks", :action => 'index' 
    contacts_issues_routes.connect "projects/:project_id/contacts/:contact_id/new_task", :conditions => { :method => :post }, :action => 'new' 
    contacts_issues_routes.connect "contacts/tasks", :action => 'index'
  end

  map.with_options :controller => 'contacts_duplicates' do |contacts_issues_routes|  
    contacts_issues_routes.connect "contacts/:contact_id/duplicates"
  end
  
  map.with_options :controller => 'deal_categories' do |categories|
    categories.connect 'projects/:project_id/deal_categories/new', :action => 'new'
  end

  map.with_options :controller => 'sale_funel' do |sale_funel|
    sale_funel.connect 'projects/:project_id/sale_funel', :action => 'index'
    sale_funel.connect 'sale_funel', :action => 'index'
    sale_funel.connect "sale_funel/:action"
  end

  map.with_options :controller => 'deals' do |deals_routes|
    deals_routes.connect "deals", :action => 'index'
    deals_routes.connect "projects/:project_id/deals", :action => 'index'
    deals_routes.connect "projects/:project_id/deals/create", :conditions => { :method => :post }, :action => 'create'
    deals_routes.connect "projects/:project_id/deals/new", :conditions => { :method => :get }, :action => 'new'
    deals_routes.connect "deals/:id", :conditions => { :method => :get }, :action => 'show', :id => /\d+/
    deals_routes.connect "deals/:id/update", :conditions => { :method => :post }, :action => 'update', :id => /\d+/
    deals_routes.connect "deals/:id/destroy", :conditions => { :method => :post}, :action => 'destroy', :id => /\d+/
    deals_routes.connect "deals/:id/edit", :conditions => { :method => :get }, :action => 'edit', :id => /\d+/
    deals_routes.connect "deals/context_menu", :action => "context_menu"
    deals_routes.connect "deals/bulk_destroy", :action => "bulk_destroy"
    deals_routes.connect "deals/bulk_edit", :action => "bulk_edit"
    deals_routes.connect "deals/bulk_update", :action => "bulk_update"
  end
  
  map.with_options :controller => 'notes' do |notes_routes|
    notes_routes.connect "notes/:note_id", :conditions => { :method => :get }, :action => 'show', :note_id => /\d+/
    notes_routes.connect "notes/show/:note_id", :conditions => { :method => :get }, :action => 'show', :note_id => /\d+/
    notes_routes.connect "notes/:note_id/edit", :conditions => { :method => :get }, :action => 'edit', :note_id => /\d+/
    notes_routes.connect "notes/:note_id/update", :conditions => { :method => :post }, :action => 'update', :note_id => /\d+/
    notes_routes.connect "notes/:note_id/destroy_note", :action => 'destroy_note', :note_id => /\d+/
    notes_routes.connect "notes/add_note", :action => 'add_note'
    notes_routes.connect "notes/destroy", :action => 'destroy'
  end
  
  map.connect "users/new_from_contact", :controller => "users", :action => 'new_from_contact'
  map.connect "auto_completes/contact_tags", :controller => "auto_completes", :action => 'contact_tags'
  map.connect "contacts_duplicates/:action", :controller => "contacts_duplicates"
  map.connect "contacts_projects/:action", :controller => "contacts_projects"
  map.connect "contacts_tags/:action", :controller => "contacts_tags"
  map.connect "contacts_tasks/:action", :controller => "contacts_tasks"
  map.connect "contacts_vcf/:action", :controller => "contacts_vcf"
  map.connect "deal_categories/:action", :controller => "deal_categories"
  map.connect "deal_contacts/:action", :controller => "deal_contacts"
  map.connect "deal_statuses/:action", :controller => "deal_statuses"
  map.connect "deals_tasks/:action", :controller => "deals_tasks"
  map.connect "contacts_settings/:action", :controller => "contacts_settings"
  map.connect "contacts_mailer/:action", :controller => "contacts_mailer"
  map.connect "deals_tasks/:action", :controller => "deals_tasks"
  map.connect "attachments/thumbnail", :controller => "attachments", :action => 'thumbnail'
    
end