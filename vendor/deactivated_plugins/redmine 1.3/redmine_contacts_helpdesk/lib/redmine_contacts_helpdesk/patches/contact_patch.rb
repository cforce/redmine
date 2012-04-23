module RedmineContactsHelpdesk
  module Patches    
    
    module ContactPatch
      def self.included(base) # :nodoc: 
        base.class_eval do    
          unloadable # Send unloadable so it will not be unloaded in development
          has_many :journals, :through => :contact_journals
          has_many :contact_journals, :dependent => :delete_all
        end  
      end  
    end
    
  end
end


Dispatcher.to_prepare do  

  unless Contact.included_modules.include?(RedmineContactsHelpdesk::Patches::ContactPatch)
    Contact.send(:include, RedmineContactsHelpdesk::Patches::ContactPatch)
  end

end