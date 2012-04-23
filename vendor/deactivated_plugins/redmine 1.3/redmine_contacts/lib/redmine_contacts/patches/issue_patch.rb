require_dependency 'issue'  
 
# Patches Redmine's Issues dynamically. Adds a relationship
# Issue +has_many+ to ArchDecisionIssue
# Copied from dvandersluis' redmine_resources plugin: 
# http://github.com/dvandersluis/redmine_resources/blob/master/lib/resources_issue_patch.rb
module RedmineContacts
  module Patches    
    
    module IssuePatch
      def self.included(base) # :nodoc: 
        base.class_eval do    
          unloadable # Send unloadable so it will not be unloaded in development
          has_and_belongs_to_many :contacts, :order => "last_name, first_name", :uniq => true
        end  
      end  
    end  

       

  end
end

Dispatcher.to_prepare do  

  unless Issue.included_modules.include?(RedmineContacts::Patches::IssuePatch)
    Issue.send(:include, RedmineContacts::Patches::IssuePatch)
  end
end

