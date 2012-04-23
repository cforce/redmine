require 'dispatcher'  

begin
  require_library_or_gem 'RMagick' unless Object.const_defined?(:Magick)
rescue LoadError
  # RMagick is not available
end

# Patches
require 'redmine_contacts/patches/compatibility_patch'

require 'redmine_contacts/patches/issue_patch'
require 'redmine_contacts/patches/project_patch'
require 'redmine_contacts/patches/tag_patch'
require 'redmine_contacts/patches/mailer_patch'
require 'redmine_contacts/patches/attachments_controller_patch' 
require 'redmine_contacts/patches/auto_completes_controller_patch'
require 'redmine_contacts/patches/users_controller_patch'
require 'redmine_contacts/patches/my_controller_patch'
require 'redmine_contacts/patches/custom_fields_helper_patch'
require 'redmine_contacts/patches/settings_controller_patch'

require 'redmine_contacts/wiki_macros/contacts_wiki_macros' 

# Dir['redmine_contacts/hooks/*.rb'].each {|file| require File.basename(file) }

# Hooks
require 'redmine_contacts/hooks/views_projects_hook'       
require 'redmine_contacts/hooks/views_issues_hook'       
require 'redmine_contacts/hooks/views_users_hook' 
require 'redmine_contacts/hooks/views_layouts_hook' 
require 'redmine_contacts/hooks/views_custom_fields_hook' 

# Plugins
require 'acts_as_viewable/init'
require 'acts_as_taggable_contacts/lib/acts_as_taggable_contacts'

module RedmineContacts
  
  # class C08de5896ae031369f5a0f9de2d714bb5
  #   def self.name() "redmine_contacts" end
  # end
  # 
  # if ActiveRecord::Migration.connection.table_exists?(:schema_migrations) && Engines::Plugin::Migrator.current_version(C08de5896ae031369f5a0f9de2d714bb5) < 20
  #   raise "===========================================================\n" +  
  #         "YOU SHOULD USE VERSION < 2.1 PRO OR LIGHT FOR UPDATE PLUGIN\n" +
  #         "==========================================================="  
  # end

  def self.settings() Setting[:plugin_contacts] end
  
  def self.list_partial
    return RedmineContacts.settings[:list_partial_style] if %w(list list_excerpt list_cards).include? RedmineContacts.settings[:list_partial_style]
    return 'list_excerpt'
  end    
    
end



