require File.dirname(__FILE__) + '/../test_helper'      
require 'contacts_projects_controller'

class ContactsProjectsControllerTest < ActionController::TestCase  
  fixtures :projects,
           :users,
           :roles,
           :members,
           :member_roles,
           :versions,
           :trackers,
           :projects_trackers,
           :enabled_modules,
           :enumerations,
           :attachments,
           :workflows,
           :time_entries,
           :contacts,
           :contacts_projects,
           :deals,
           :notes
  
  def setup
    RedmineContacts::TestCase.prepare
    @controller = ContactsProjectsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    User.current = nil    
  end
  
  test "should delete project" do
    @request.session[:user_id] = 1
    contact = Contact.find(1)
    assert RedmineContacts::TestCase.is_arrays_equal(contact.project_ids, [1, 2])
    # assert_equal '12', "#{contact.project_ids} || #{contact.projects.map(&:name).join(', ')} #{Project.find(1).contacts.map(&:name).join(', ')},  #{Project.find(2).name}"
    xhr :post, :delete, :project_id => 1, :disconnect_project_id => 2, :contact_id => 1
    assert_response :success
    assert_select_rjs :replace_html, 'contact_projects'
    
    contact.reload
    assert_equal [1], contact.project_ids
  end  
  
  test "should not delete last project" do
    @request.session[:user_id] = 1
    contact = Contact.find(1)
    assert RedmineContacts::TestCase.is_arrays_equal(contact.project_ids, [1, 2])
    # assert_equal '12', "#{contact.project_ids} || #{contact.projects.map(&:name).join(', ')} #{Project.find(1).contacts.map(&:name).join(', ')},  #{Project.find(2).name}"
    xhr :post, :delete, :project_id => 1, :disconnect_project_id => 2, :contact_id => 1
    assert_response :success
    xhr :post, :delete, :project_id => 1, :disconnect_project_id => 1, :contact_id => 1
    assert_response 403
    
    contact.reload
    assert_equal [1], contact.project_ids
  end

  test "should add project" do
    @request.session[:user_id] = 1

    xhr :post, :add, :project_id => "ecookbook", :new_project_id => 2, :contact_id => 2
    assert_response :success
    assert_select_rjs :replace_html, 'contact_projects'
    contact = Contact.find(2)
    assert RedmineContacts::TestCase.is_arrays_equal(contact.project_ids, [1, 2])
  end  



  

end
