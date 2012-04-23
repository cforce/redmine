require 'redmine_contacts_invoices/hooks/views_context_menues_hook'
require 'redmine_contacts_invoices/hooks/views_layouts_hook'
require 'redmine_contacts_invoices/hooks/views_custom_fields_hook'

require 'redmine_contacts_invoices/patches/project_patch'
require 'redmine_contacts_invoices/patches/settings_controller_patch'
require 'redmine_contacts_invoices/patches/custom_fields_helper_patch'

module RedmineContactsInvoices

  def self.settings() Setting[:plugin_redmine_contacts_invoices] end
    
  def self.invoice_lines_units
    settings[:units].blank? ? [] : settings[:units].split("\n")
  end
  
  def self.available_locales
    Dir.glob(File.join(Engines.plugins[:redmine_contacts_invoices].directory, 'config', 'locales', '*.yml')).collect {|f| File.basename(f).split('.').first}.collect(&:to_sym)
    # [:en, :de, :fr, :ru]
  end
  
  def self.rate_plugin_installed?
    @@rate_plugin_installed ||= Redmine::Plugin.installed?(:redmine_rate)
  end

  module Hooks
    class ViewLayoutsBaseHook < Redmine::Hook::ViewListener     
      render_on :view_layouts_base_html_head, :inline => "<%= stylesheet_link_tag :contacts_invoices, :plugin => 'redmine_contacts_invoices' %>"
    end   
  end

end

