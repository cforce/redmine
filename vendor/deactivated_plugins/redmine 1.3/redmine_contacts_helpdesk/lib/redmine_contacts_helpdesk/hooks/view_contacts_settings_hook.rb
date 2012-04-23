module RedmineContactsHelpdesk
  module Hooks
    class ViewsContactsSettingsHook < Redmine::Hook::ViewListener
      def add_contacts_project_settings_tab(context={})
        if User.current.allowed_to?(:edit_helpdesk_settings, context[:project])
        	context[:tabs].push({ :name => 'contacts_helpdesk',
        		:action => :manage_contacts,
        		:partial => 'projects/settings/contacts_helpdesk_settings',
        		:label => :label_helpdesk })
        end
      end
    end
  end
end      