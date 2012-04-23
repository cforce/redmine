require File.dirname(__FILE__) + '/../../test_helper'  
# require File.dirname(__FILE__) + '/../../../../../test/test_helper'

class ApiTest::HelpdeskTest < ActionController::IntegrationTest
  fixtures :all, :projects, :contacts, :deals, :notes

  def setup
    Setting.rest_api_enabled = '1'
    RedmineContactsHelpdesk::TestCase.prepare
  end

  test "POST /contacts_helpdesks/email_note.xml" do
    Issue.find(1).contacts << Contact.find(1)
    ActiveSupport::TestCase.should_allow_api_authentication(:post,
                                    '/contacts_helpdesks/email_note.xml',
                                    {:message => {:issue_id => 1, :content => 'Test note', :status_id => 3}},
                                    {:success_code => :created})
  
    assert_difference('Journal.count') do
      post '/contacts_helpdesks/email_note.xml', {:message => {:issue_id => 1, :content => 'Test note', :status_id => 3}}, :authorization => credentials('admin')
    end

    journal = Journal.first(:order => 'id DESC')
    assert_equal 'Test note', journal.notes

    assert_response :created
    assert_equal 'application/xml', @response.content_type
    assert_tag 'message', :child => {:tag => 'journal_id', :content => journal.id.to_s}
  end

  
  def credentials(user, password=nil)
    ActionController::HttpAuthentication::Basic.encode_credentials(user, password || user)
  end
end
