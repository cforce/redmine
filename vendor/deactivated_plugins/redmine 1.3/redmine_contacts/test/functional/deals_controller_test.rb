require File.dirname(__FILE__) + '/../test_helper'
require 'deals_controller'

class DealsControllerTest < ActionController::TestCase 
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
           :notes
  # Replace this with your real tests.    
  
  def setup
    RedmineContacts::TestCase.prepare
    Setting.default_language = 'en'
    
  end

  test "should get index" do     
    # log_user('admin', 'admin')   
    @request.session[:user_id] = 1
    
    
    get :index
    assert_response :success
    assert_template :index
    assert_not_nil assigns(:deals)
    assert_nil assigns(:project)
    assert_select 'a', /First deal with contacts/
    # private projects hidden
    # assert_no_tag :tag => 'a', :content => /Issue of a private subproject/
    # assert_no_tag :tag => 'a', :content => /Issue on project 2/
    # project column
    # assert_tag :tag => 'th', :content => /Project/
  end
  
  test "should not get closed in index" do     
    # log_user('admin', 'admin')   
    @request.session[:user_id] = 1
    
    
    get :index
    assert_response :success
    assert_template :index
    assert_select 'a', /First deal with contacts/
    assert_select 'table.contacts.index h1.deal_name a', {:count => 0, :text => /Closed deal/}
    
  end      

  test "should get closed index with pages" do     
    # log_user('admin', 'admin')   
    @request.session[:user_id] = 1
    
    
    get :index, :page => 2, :page_size => 1, :status_id => ""
    assert_response :success
    assert_template :index
    assert_select 'table.contacts.index h1.deal_name a', /Deal without contact/
    assert_select 'table.contacts.index h1.deal_name a', {:count => 0, :text => /First deal with contacts/}
    
  end      
        
  
  test "should get index with filters" do 
    @request.session[:user_id] = 1
    
    get :index
    assert_response :success
    assert_template :index
    assert_not_nil assigns(:deals)
    assert_nil assigns(:project)  

    xhr :post, :index, :status_id => ""
    assert_select 'table.contacts.index h1.deal_name a', /First deal with contacts/
    assert_select 'table.contacts.index h1.deal_name a', /Second deal with contacts/    
    assert_select 'table.contacts.index h1.deal_name a', /Delevelop redmine plugin/

    xhr :post, :index, :status_id => "2"
    # assert_select 'a', /First deal with contacts/, 0
    # assert_select 'a', /Second deal with contacts/, 0    
    assert_select 'table.contacts.index h1.deal_name a', /Delevelop redmine plugin/
    assert_select 'table.contacts.index h1.deal_name a', {:count => 0, :text => "Second deal with contacts"}

    xhr :post, :index, :assigned_to_id => "1"
    # assert_select 'a', /First deal with contacts/, 0
    # assert_select 'a', /Second deal with contacts/, 0    
    assert_select 'table.contacts.index h1.deal_name a', /First deal with contacts/

  end  
  
  test "should get index with project" do
    # log_user('admin', 'admin')   
    @request.session[:user_id] = 3
    
    get :index, :project_id => 1
    assert_response :success
    assert_template :index
    assert_not_nil assigns(:deals)
    assert_not_nil assigns(:project)
    assert_tag :tag => 'a', :content => /First deal with contacts/     
    assert_no_tag :tag => 'a', :content => /Second deal with contacts/
    assert_tag :tag => 'h3', :content => /Recently viewed/
    # private projects hidden
    # assert_no_tag :tag => 'a', :content => /Issue of a private subproject/
    # assert_no_tag :tag => 'a', :content => /Issue on project 2/
    # project column
    # assert_tag :tag => 'th', :content => /Project/
  end        
  
  test "should post create" do
    @request.session[:user_id] = 1
    assert_difference 'Deal.count' do
      post :create, :project_id => 1,  
                    :deal => {:price => 5500, 
                              :name => "New created deal 1", 
                              :background =>"Background of new created deal", 
                              :contact_id => 2, 
                              :assigned_to_id => 3, 
                              :category_id => 1}

    end
    assert_redirected_to :controller => 'deals', :action => 'show', :id => Deal.last.id

    deal = Deal.find_by_name('New created deal 1')
    assert_not_nil deal
    assert_equal 1, deal.category_id
    assert_equal 2, deal.contact_id
    assert_equal 3, deal.assigned_to_id
  end  
  
  test "should get show" do 
    @request.session[:user_id] = 1
    get :show, :id => 1
    assert_response :success
    assert_template 'show'
    assert_not_nil assigns(:deal)
    assert_equal Deal.find(1), assigns(:deal)
  end
  
  test "should get show with statuses" do 
    project = Project.find(1)
    project.deal_statuses << DealStatus.find(1)
    project.deal_statuses << DealStatus.find(2)
    project.save
    
    assert_equal ['Pending', 'Won', 'Lost'], DealStatus.all.map(&:name)
    assert_equal ['Pending', 'Won'], project.deal_statuses.map(&:name)
    @request.session[:user_id] = 1
    get :show, :id => 1
    assert_response :success
    assert_template 'show'
    assert_select '#deal_status_id', /Pending/
    assert_select '#deal_status_id', /Won/
    assert_select '#deal_status_id', {:count => 0, :text => /Lost/}
    
  end
  
  test "should get edit" do 
    @request.session[:user_id] = 1
    get :edit, :id => 1
    assert_response :success
    assert_template 'edit'
    assert_not_nil assigns(:deal)
    assert_equal Deal.find(1), assigns(:deal)
  end
  
  test "should put update" do
    @request.session[:user_id] = 1

    deal = Deal.find(1)
    old_name = deal.name
    new_name = 'Name modified by DealControllerTest#test_put_update'
    
    put :update, :id => 1, :deal => {:name => new_name, :currency => 2, :price => 23000}
    assert_redirected_to :action => 'show', :id => '1'
    deal.reload
    assert_equal 23000, deal.price

    get :show, :id => 1
    assert_response :success
    assert_select 'td.subject_info', /£23 000.00/

    assert_equal new_name, deal.name
  end
  
  test "should bulk edit deals" do 
    @request.session[:user_id] = 1
    post :bulk_edit, :ids => [1, 2, 4]   
    assert_response :success
    assert_template 'bulk_edit'
    assert_not_nil assigns(:deals)        
  end  
  
  test "should not bulk edit deals by deny user" do 
    @request.session[:user_id] = 4
    post :bulk_edit, :ids => [1, 2, 4]
    assert_response 403
  end  
  
  test "should put bulk update " do
    @request.session[:user_id] = 1

    put :bulk_update, :ids => [1, 2, 4], 
                      :deal => {:assigned_to_id => 2,
                                :category_id => 2,
                                :currency => 1},
                      :note => {:content => "Bulk deals edit note content"}
                      
    assert_redirected_to :controller => 'deals', :action => 'index', :project_id => nil
    
    deals = Deal.find(1, 2, 4)
    
    assert_equal [2], deals.collect(&:assigned_to_id).uniq
    assert_equal [2], deals.collect(&:category_id).uniq
    assert_equal [1], deals.collect(&:currency).uniq

    assert_equal 3, Note.count(:conditions =>  {:content => "Bulk deals edit note content"})
  end
  
  test "should post index live search" do 
    @request.session[:user_id] = 1
    xhr :post, :index, :search => "First", :period => "all", :assigned_to_id => "", :status_id => "o"
    assert_response :success
    assert_template '_list'
    assert_tag :tag => 'a', :content => /First deal with contacts/
  end
  
  test "should post index live search in project" do 
    @request.session[:user_id] = 1
    xhr :post, :index, :search => "First", :project_id => 'ecookbook'
    assert_response :success
    assert_template '_list'
    assert_tag :tag => 'a', :content => /First deal with contacts/
  end
  
  
end
