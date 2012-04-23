require_dependency 'custom_fields_helper'

module RedmineContacts
  module Patches    

    module CustomFieldsHelperPatch
      def self.included(base) # :nodoc:
        base.send(:include, InstanceMethods)

        base.class_eval do
          alias_method_chain :custom_fields_tabs, :test_tab
        end
      end

      module InstanceMethods
        # Adds a rates tab to the user administration page
        def custom_fields_tabs_with_test_tab
          tabs = custom_fields_tabs_without_test_tab
          tabs << {:name => 'ContactCustomField', :partial => 'custom_fields/index', :label => :label_contact_plural}
          tabs << {:name => 'DealCustomField', :partial => 'custom_fields/index', :label => :label_deal_plural}
          tabs << {:name => 'NoteCustomField', :partial => 'custom_fields/index', :label => :label_note_plural}
          return tabs
        end
      end
      
    end
    
  end
end

Dispatcher.to_prepare do  
  unless CustomFieldsHelper.included_modules.include?(RedmineContacts::Patches::CustomFieldsHelperPatch)
    CustomFieldsHelper.send(:include, RedmineContacts::Patches::CustomFieldsHelperPatch)
  end

end