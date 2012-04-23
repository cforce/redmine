require 'dispatcher'   

require 'redmine_contacts_helpdesk/patches/compatibility_patch'
require 'redmine_contacts_helpdesk/patches/issues_controller_patch'
require 'redmine_contacts_helpdesk/patches/journal_patch'
require 'redmine_contacts_helpdesk/patches/contact_patch'

require 'redmine_contacts_helpdesk/hooks/view_issues_hook'
require 'redmine_contacts_helpdesk/hooks/view_journals_hook'
require 'redmine_contacts_helpdesk/hooks/view_contacts_settings_hook'
require 'redmine_contacts_helpdesk/hooks/controller_contacts_duplicates_hook'

require 'redmine_contacts_helpdesk/wiki_macros/contacts_helpdesk_wiki_macro'

class HelpdeskSettings
  # Returns the value of the setting named name
  def self.[](name, project_id)
    !ContactsSetting[name, project_id].blank? ? ContactsSetting[name, project_id] : RedmineContactsHelpdesk.settings[name]
  end

end

module RedmineContactsHelpdesk

  def self.settings() Setting[:plugin_redmine_contacts_helpdesk] end

  module Hooks
    class ViewLayoutsBaseHook < Redmine::Hook::ViewListener   
      def view_layouts_base_html_head(context={})
        return content_tag(:style, "#admin-menu a.helpdesk { background-image: url('#{image_path('user_comment.png', :plugin => 'redmine_contacts_helpdesk')}'); }", :type => 'text/css')
      end  
    end   
  end

end

