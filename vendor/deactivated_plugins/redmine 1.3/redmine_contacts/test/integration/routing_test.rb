require File.expand_path('../../test_helper', __FILE__)

class RoutingTest < ActionController::IntegrationTest

  test "contacts" do
    # REST actions
    assert_routing({ :path => "/contacts", :method => :get }, { :controller => "contacts", :action => "index" })
    assert_routing({ :path => "/contacts.xml", :method => :get }, { :controller => "contacts", :action => "index", :format => 'xml' })
    assert_routing({ :path => "/contacts.atom", :method => :get }, { :controller => "contacts", :action => "index", :format => 'atom' })
    assert_routing({ :path => "/contacts/notes", :method => :get }, { :controller => "contacts", :action => "contacts_notes" })
    assert_routing({ :path => "/contacts/1", :method => :get }, { :controller => "contacts", :action => "show", :id => '1'})
    assert_routing({ :path => "/contacts/1/edit", :method => :get }, { :controller => "contacts", :action => "edit", :id => '1'})
    assert_routing({ :path => "/contacts/context_menu", :method => :get }, { :controller => "contacts", :action => "context_menu" })
    assert_routing({ :path => "/projects/23/contacts", :method => :get }, { :controller => "contacts", :action => "index", :project_id => '23'})
    assert_routing({ :path => "/projects/23/contacts.xml", :method => :get }, { :controller => "contacts", :action => "index", :project_id => '23', :format => 'xml'})
    assert_routing({ :path => "/projects/23/contacts.atom", :method => :get }, { :controller => "contacts", :action => "index", :project_id => '23', :format => 'atom'})
    assert_routing({ :path => "/projects/23/contacts/notes", :method => :get }, { :controller => "contacts", :action => "contacts_notes", :project_id => '23'})

    assert_routing({ :path => "/projects/23/contacts/2/edit_tags", :method => :post }, { :controller => "contacts", :action => "edit_tags", :project_id => '23', :id => '2' })
    assert_routing({ :path => "/contacts.xml", :method => :post }, { :controller => "contacts", :action => "create", :format => 'xml' })

    assert_routing({ :path => "/contacts/1.xml", :method => :put }, { :controller => "contacts", :action => "update", :format => 'xml', :id => "1" })

    # should_route :get, "/contacts.atom", :controller => 'contacts', :action => 'index', :format => 'atom'
    # should_route :get, "/contacts.xml", :controller => 'contacts', :action => 'index', :format => 'xml'
    # should_route :get, "/projects/23/contacts", :controller => 'contacts', :action => 'index', :project_id => '23'
    # should_route :get, "/projects/23/contacts.atom", :controller => 'contacts', :action => 'index', :project_id => '23', :format => 'atom'
    # should_route :get, "/projects/23/contacts.xml", :controller => 'contacts', :action => 'index', :project_id => '23', :format => 'xml'
    # should_route :get, "/contacts/64", :controller => 'contacts', :action => 'show', :id => '64'
    # should_route :get, "/contacts/64.atom", :controller => 'contacts', :action => 'show', :id => '64', :format => 'atom'
    # should_route :get, "/contacts/64.xml", :controller => 'contacts', :action => 'show', :id => '64', :format => 'xml'
    # 
    # should_route :get, "/projects/23/contacts/new", :controller => 'contacts', :action => 'new', :project_id => '23'
    # should_route :post, "/projects/23/contacts", :controller => 'contacts', :action => 'create', :project_id => '23'
    # should_route :post, "/contacts.xml", :controller => 'contacts', :action => 'create', :format => 'xml'
    #   
    # should_route :get, "/contacts/64/edit", :controller => 'contacts', :action => 'edit', :id => '64'
    # # TODO: Should use PUT
    # should_route :post, "/contacts/64/edit", :controller => 'contacts', :action => 'edit', :id => '64'
    # should_route :put, "/contacts/1.xml", :controller => 'contacts', :action => 'update', :id => '1', :format => 'xml'
    # 
    # # TODO: Should use DELETE
    # should_route :post, "/contacts/64/destroy", :controller => 'contacts', :action => 'destroy', :id => '64'
    # should_route :delete, "/contacts/1.xml", :controller => 'contacts', :action => 'destroy', :id => '1', :format => 'xml'
    # 
    # # Extra actions
    # should_route :get, "/contacts/bulk_edit", :controller => 'issues', :action => 'bulk_edit'
    # should_route :post, "/contacts/bulk_edit", :controller => 'issues', :action => 'bulk_update'
  end
  
  test "deals" do
    # REST actions
    assert_routing({ :path => "/deals", :method => :get }, { :controller => "deals", :action => "index" })
    # assert_routing({ :path => "/deals.xml", :method => :get }, { :controller => "deals", :action => "index", :format => 'xml' })
    # assert_routing({ :path => "/deals.atom", :method => :get }, { :controller => "deals", :action => "index", :format => 'atom' })
    assert_routing({ :path => "/deals/1", :method => :get }, { :controller => "deals", :action => "show", :id => '1'})
    assert_routing({ :path => "/deals/1/edit", :method => :get }, { :controller => "deals", :action => "edit", :id => '1'})
    assert_routing({ :path => "/projects/23/deals", :method => :get }, { :controller => "deals", :action => "index", :project_id => '23'})
    # assert_routing({ :path => "/projects/23/deals.xml", :method => :get }, { :controller => "deals", :action => "index", :project_id => '23', :format => 'xml'})
    # assert_routing({ :path => "/projects/23/deals.atom", :method => :get }, { :controller => "deals", :action => "index", :project_id => '23', :format => 'atom'})
    # assert_routing({ :path => "/projects/23/deals/notes", :method => :get }, { :controller => "deals", :action => "deals_notes", :project_id => '23'})

    # assert_routing({ :path => "/deals.xml", :method => :post }, { :controller => "deals", :action => "create", :format => 'xml' })
    # 
    # assert_routing({ :path => "/deals/1.xml", :method => :put }, { :controller => "deals", :action => "update", :format => 'xml', :id => "1" })
  end
end
