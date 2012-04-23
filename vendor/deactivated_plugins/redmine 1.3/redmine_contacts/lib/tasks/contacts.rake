namespace :redmine do
  namespace :contacts do

    desc <<-END_DESC
Drop settings.

  rake redmine:contacts:drop_settings RAILS_ENV="production" plugin="plugin_contacts"
  
Plugins:
  plugin_contacts: Redmine CRM plugin
  plugin_redmine_contacts_helpdesk: Redmine Helpdesk plugin
  plugin_redmine_contacts_invoices: Redmine Invoices plugin
  
END_DESC

    task :drop_settings => :environment do
      plugin_name = ENV['plugin']
      Setting[plugin_name.to_sym] = {} if plugin_name
    end

       
  end
end
