require File.dirname(__FILE__) + '/../test_helper'  
require File.dirname(__FILE__) + '/../../../../../test/test_helper' 

class DeleteTagTest < ActionController::IntegrationTest
  fixtures :projects,
           :users,
           :roles,
           :members,
           :member_roles,
           :issues,
           :issue_statuses,
           :versions,
           :trackers,
           :projects_trackers,
           :issue_categories,
           :enabled_modules,
           :enumerations,
           :attachments,
           :workflows,
           :custom_fields,
           :custom_values,
           :custom_fields_projects,
           :custom_fields_trackers,
           :time_entries,
           :journals,
           :journal_details,
           :queries,
           :contacts,
           :contacts_projects,
           :deals,
           :notes,
           :tags,
           :taggings
    
  def setup
    RedmineContacts::TestCase.prepare

    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.env['HTTP_REFERER'] = '/'
  end  

  test "Contacts with deleted tags should opens" do
    log_user("admin", "admin")
    
    assert_not_nil User.first
    
    get "contacts"
    assert_response :success
    
    get "contacts/1"
    assert_response :success
    
    get "settings/plugin/contacts"
    # assert_select 'div#tab-content-tags table td a', "main"
    
    contact = Contact.find(1)
    contact.tag_list = "test_tag"
    contact.save
    tag_id = contact.tags.last.id
    
    assert_response :success
    delete "contacts_tags/destroy/#{tag_id}"
    assert_response :success

    get "contacts/1"
    assert_response :success
   end  
end
