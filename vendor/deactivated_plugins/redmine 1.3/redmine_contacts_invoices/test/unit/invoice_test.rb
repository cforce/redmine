require File.dirname(__FILE__) + '/../test_helper'

class InvoiceTest < ActiveSupport::TestCase
  fixtures :invoices, 
           :contacts,
           :roles

  def setup
    @project_a = Project.create(:name => "Test_a", :identifier => "testa")
    @project_b = Project.create(:name => "Test_b", :identifier => "testb")

    @contact1 = Contact.create(:first_name => "Contact_1", :projects => [@project_a])
    @invoice1 = Invoice.create(:number => "INV/20121212-1", :contact => @contact1, :project => @project_a, :status_id => Invoice::DRAFT_INVOICE)
  end
  
  test "available tags should return list of distinct tags" do
  end


end
