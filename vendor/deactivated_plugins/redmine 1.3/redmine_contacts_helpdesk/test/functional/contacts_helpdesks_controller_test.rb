require File.dirname(__FILE__) + '/../test_helper'

class ContactsHelpdesksControllerTest < ActionController::TestCase
  fixtures :users, :projects, :enabled_modules, :roles, :members, :member_roles, :issues, :issue_statuses, :trackers, :enumerations,
           :contacts,
            :contacts_projects,
            :deals,
            :notes,
            :tags,
            :taggings
  
  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
