#custom routes for this plugin
ActionController::Routing::Routes.draw do |map|
  map.connect "helpdesk_mailer", :controller => "contacts_helpdesk_mailer", :action => "index"
  map.connect "contacts_helpdesks/save_settings", :controller => "contacts_helpdesks", :action => "save_settings"
  map.connect "contacts_helpdesks/get_mail", :controller => "contacts_helpdesks", :action => "get_mail"
  map.connect "contacts_helpdesks/test_connection", :controller => "contacts_helpdesks", :action => "test_connection"
  map.connect "contacts_helpdesks/email_note.:format", :controller => "contacts_helpdesks", :action => "email_note"
end