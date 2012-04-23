module RedmineContactsHelpdesk
  module Hooks
    class ControllerContactsDuplicatesHook < Redmine::Hook::ViewListener
      def controller_contacts_duplicates_merge(context={})
        context[:duplicate].contact_journals << context[:contact].contact_journals
      end
    end
  end
end      