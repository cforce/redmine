require File.dirname(__FILE__) + '/../test_helper'      
require 'contacts_helpdesk_mailer_controller'

# Re-raise errors caught by the controller.
class ContactsHelpdeskMailerController; def rescue_action(e) raise e end; end

class ContactsHelpdeskMailerControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  fixtures :users, :projects, :enabled_modules, :roles, :members, :member_roles, :issues, :issue_statuses, :trackers, :enumerations,
           :contacts,
            :contacts_projects,
            :deals,
            :notes,
            :tags,
            :taggings
  
  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures/contacts_helpdesk_mailer'
  
  def setup
    RedmineContactsHelpdesk::TestCase.prepare
    
    @controller = ContactsHelpdeskMailerController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    User.current = nil
  end
  
  def test_should_create_issue
    # Enable API and set a key
    Setting.mail_handler_api_enabled = 1
    Setting.mail_handler_api_key = 'secret'
    
    post :index, :key => 'secret', :issue => {:project => 'ecookbook', :status => 'Closed', :tracker => 'Bug', :assigned_to => 'jsmith'}, :email => IO.read(File.join(FIXTURES_PATH, 'new_issue_new_contact.eml'))
    assert_response 201
    assert_not_nil Contact.find_by_first_name('New')
  end
end
