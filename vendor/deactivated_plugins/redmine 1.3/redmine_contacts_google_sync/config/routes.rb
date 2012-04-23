#custom routes for this plugin
ActionController::Routing::Routes.draw do |map|
  map.connect "projects/:project_id/contacts/google", :controller => 'google_contacts', :conditions => { :method => [:get, :post] }, :action => 'index' #post for live search   
  map.connect "projects/:project_id/contacts/google_drop_token", :controller => 'google_contacts', :action => 'drop_token'
  map.connect "projects/:project_id/contacts/google_import_contacts", :controller => 'google_contacts', :action => 'import_contacts'
  map.connect "projects/:project_id/contacts/google_authorize", :controller => 'google_contacts', :action => 'google_authorize'
end