require File.dirname(__FILE__) + '/../test_helper'  

class ContactTest < ActiveSupport::TestCase
  fixtures :contacts

  # Replace this with your real tests.
  test "Should get first by email" do
    emails = ["marat@mail.ru", "domoway.mail.ru"]
    assert_equal 2, Contact.find_by_emails(emails).count
  end

  test "Should get first by second email" do
    emails = ["marat@mail.com"]
    assert_equal 1, Contact.find_by_emails(emails).count
  end

  
end
