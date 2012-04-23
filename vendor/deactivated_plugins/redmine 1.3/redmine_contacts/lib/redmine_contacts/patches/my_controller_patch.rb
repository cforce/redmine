module RedmineContacts
  module Patches    

    module MyControllerPatch
      def self.included(base) # :nodoc:
        base.class_eval do
          helper :deals
        end
      end
    end
    
  end
end

Dispatcher.to_prepare do  
  unless MyController.included_modules.include?(RedmineContacts::Patches::MyControllerPatch)
    MyController.send(:include, RedmineContacts::Patches::MyControllerPatch)
  end
end