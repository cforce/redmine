require File.dirname(__FILE__) + '/../test_helper'  
require File.dirname(__FILE__) + '/../../../../../test/test_helper' 

class CommonViewsTest < ActionController::IntegrationTest
  
  def setup
    RedmineContactsHelpdesk::TestCase.prepare

    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.env['HTTP_REFERER'] = '/'
  end  
  
  test "View project settings" do
    log_user("admin", "admin")
    get "/projects/ecookbook/settings"
    assert_response :success
  end  

  test "View helpdesk plugin settings" do
    log_user("admin", "admin")
    get "/settings/plugin/redmine_contacts_helpdesk"
    assert_response :success
  end  

end
