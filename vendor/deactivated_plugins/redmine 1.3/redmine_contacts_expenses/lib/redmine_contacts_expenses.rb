# require 'redmine_contacts_expenses/hooks/views_context_menues_hook'
# require 'redmine_contacts_expenses/hooks/views_layouts_hook'
# require 'redmine_contacts_expenses/hooks/views_custom_fields_hook'
# 
# require 'redmine_contacts_expenses/patches/project_patch'
# require 'redmine_contacts_expenses/patches/settings_controller_patch'
# require 'redmine_contacts_expenses/patches/custom_fields_helper_patch'


module RedmineContactsInvoices

  def self.settings() Setting[:plugin_redmine_contacts_expenses] end
    
  module Hooks
    class ViewLayoutsBaseHook < Redmine::Hook::ViewListener     
      render_on :view_layouts_base_html_head, :inline => "<%= stylesheet_link_tag :contacts_expenses, :plugin => 'redmine_contacts_expenses' %>"
    end   
  end

end

