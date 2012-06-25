module RedmineIssuesPdfExport
  class ViewHooks < Redmine::Hook::ViewListener
    render_on :view_issues_index_bottom, :partial => 'hooks/redmine_issues_pdf/view_issues_index_bottom'
  end
end