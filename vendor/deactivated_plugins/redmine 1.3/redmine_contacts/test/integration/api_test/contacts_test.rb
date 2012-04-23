require File.dirname(__FILE__) + '/../../test_helper'  
# require File.dirname(__FILE__) + '/../../../../../test/test_helper'

class ApiTest::ContactsTest < ActionController::IntegrationTest
  fixtures :all, 
     :contacts,
     :contacts_projects,
     :deals,
     :notes,
     :tags,
     :taggings

  def setup
    Setting.rest_api_enabled = '1'
    RedmineContacts::TestCase.prepare
  end

  test "GET /contacts.xml" do
    # Use a private project to make sure auth is really working and not just
    # only showing public issues.
    ActiveSupport::TestCase.should_allow_api_authentication(:get, "/projects/private-child/contacts.xml")
     # test "should contain metadata" do
      get '/contacts.xml', {}, :authorization => credentials('admin')
      
      assert_tag :tag => 'contacts',
        :attributes => {
          :type => 'array',
          :total_count => assigns(:contacts_count),
          :limit => 20,
          :offset => 0
        }
    # end

  end

  # Issue 6 is on a private project
  # context "/contacts/2.xml" do
  #   should_allow_api_authentication(:get, "/contacts/2.xml")
  # end

  test "POST /contacts.xml" do
    ActiveSupport::TestCase.should_allow_api_authentication(:post,
                                    '/contacts.xml',
                                    {:contact => {:project_id => 1, :first_name => 'API test'}},
                                    {:success_code => :created})
  
      assert_difference('Contact.count') do
        post '/contacts.xml', {:contact => {:project_id => 1, :first_name => 'API test'}}, :authorization => credentials('admin')
      end

      contact = Contact.first(:order => 'id DESC')
      assert_equal 'API test', contact.first_name
  
      assert_response :created
      assert_equal 'application/xml', @response.content_type
      assert_tag 'contact', :child => {:tag => 'id', :content => contact.id.to_s}
  end

  # Issue 6 is on a private project
  test "PUT /contacts/1.xml" do
      @parameters = {:contact => {:first_name => 'API update'}}
      @headers = { :authorization => credentials('admin') }
    
      ActiveSupport::TestCase.should_allow_api_authentication(:put,
                                    '/contacts/1.xml',
                                    {:contact => {:first_name => 'API update'}},
                                    {:success_code => :ok})
  
      assert_no_difference('Contact.count') do
        put '/contacts/1.xml', @parameters, @headers
      end
  
      contact = Contact.find(1)
      assert_equal "API update", contact.first_name
    
  end
  
  def credentials(user, password=nil)
    ActionController::HttpAuthentication::Basic.encode_credentials(user, password || user)
  end
end
