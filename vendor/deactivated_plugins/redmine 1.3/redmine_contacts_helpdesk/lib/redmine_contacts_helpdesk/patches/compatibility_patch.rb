require_dependency 'mail_handler'  

module RedmineContactsHelpdesk
  module Patches    
    module MailHandlerCompatibilityPatch
      def self.included(base) # :nodoc: 
        base.class_eval do    
          unloadable # Send unloadable so it will not be unloaded in development
          alias_method :find_assignee_from_keyword, :find_user_from_keyword
        end  
      end  
    end
  end
end  

Dispatcher.to_prepare do  
  if !MailHandler.included_modules.include?(RedmineContactsHelpdesk::Patches::MailHandlerCompatibilityPatch)
    MailHandler.send(:include, RedmineContactsHelpdesk::Patches::MailHandlerCompatibilityPatch)
  end
end if false && (Redmine::VERSION.to_a.first(3).join('.') < '1.3.0')