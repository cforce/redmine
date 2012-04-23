require 'redmine'

# Budget requires the Contacts plugin

# begin
#   require 'contact_custom_field' unless Object.const_defined?('ContactCustomField')
# rescue LoadError
#   # contcts_plugin is not installed
#   raise Exception.new("ERROR: The Contacts plugin is not installed.  Please install the Contacts plugin from http://redminecrm.com/projects/contacts-plugin")
# end

require 'redmine_contacts_google_sync/hooks/view_contacts_google_sync' 

Redmine::Plugin.register :redmine_contacts_google_sync do
  name 'Redmine Contacts Google Sync plugin'
  author 'Kirill Bezrukov'
  description 'This is a plugin for Redmine Contacts plugin to add Google contacts sync'
  version '2.2.4'
  url 'http://www.redminecrm.com  '
  author_url 'mailto:kirbez@redminecrm.com'

  requires_redmine_plugin :contacts, :version_or_higher => '2.0.0'
     
end
