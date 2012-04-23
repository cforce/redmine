module RedmineContactsHelpdesk
  module Patches    
    
    module JournalPatch
      def self.included(base) # :nodoc: 
        base.class_eval do    
          unloadable # Send unloadable so it will not be unloaded in development
          has_many :contacts, :through => :contact_journals
          has_many :contact_journals, :dependent => :delete_all
        end  
      end  
    end
    
  end
end


Dispatcher.to_prepare do  

  unless Journal.included_modules.include?(RedmineContactsHelpdesk::Patches::JournalPatch)
    Journal.send(:include, RedmineContactsHelpdesk::Patches::JournalPatch)
  end

end
    