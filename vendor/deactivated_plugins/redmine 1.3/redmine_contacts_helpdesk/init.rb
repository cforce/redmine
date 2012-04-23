require 'redmine'

require 'redmine_contacts_helpdesk'

Redmine::Plugin.register :redmine_contacts_helpdesk do
  name 'Redmine Contacts Helpdesk plugin'
  author 'RedmineCRM'
  description 'This is a helpdesk plugin for Redmine'
  version '1.0.4-beta-3'
  url 'http://redminecrm.com'
  author_url 'mailto:kirbez@redminecrm.com'
  
  requires_redmine :version_or_higher => '1.2.1'   
  requires_redmine_plugin :contacts, :version_or_higher => '2.2.0'
  
  settings :default => {
    :helpdesk_answer_from => '',
    :helpdesk_first_answer_subject => "%%PROJECT%% support message [%%ISSUE_TRACKER%% #%%ISSUE_ID%%]",
    :helpdesk_first_answer_template => "Hello, %%NAME%%\n\nWe hereby confirm that we have received your message.\n\nWe will handle your request and get back to you as soon as possible.\n\nYour request has been assigned the following case ID #%%ISSUE_ID%%."
  }, :partial => 'settings/contacts_helpdesk'
  
  project_module :contacts_helpdesk do
     permission :view_mail_data, :contacts_helpdesks => [:show_original]
     permission :send_response, :issues => [:send_helpdesk_response, :email_note], 
                                :contacts_helpdesks => [:show_original]
     permission :edit_helpdesk_settings, :contacts_helpdesks => [:save_settings, :test_connection, :get_mail]
  end
  
  menu :admin_menu, :helpdesk, {:controller => 'settings', :action => 'plugin', :id => "redmine_contacts_helpdesk"}, :caption => :label_helpdesk, :param => :project_id
     
  
end

