module RedmineContactsHelpdesk
  module Hooks
    class ViewIssuesHook < Redmine::Hook::ViewListener
      render_on :view_issues_edit_notes_bottom, :partial => 'issues/contacts_helpdesk'
    end
  end
end

