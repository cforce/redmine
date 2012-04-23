require File.dirname(__FILE__) + '/../test_helper'  

class ContactsHelpdeskMailerTest < ActiveSupport::TestCase

  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures/contacts_helpdesk_mailer'

  def setup
    RedmineContactsHelpdesk::TestCase.prepare

    ActionMailer::Base.deliveries.clear
    Setting.host_name = 'mydomain.foo'
    Setting.protocol = 'http'
    Setting.plain_text_mail = '0'
    
    Setting.notified_events = Redmine::Notifiable.all.collect(&:name)
  end


  test "Should add issue and contact" do
    ActionMailer::Base.deliveries.clear
    # This email contains: 'Project: onlinestore'
    ContactsSetting[:helpdesk_created_contact_tag, Project.find_by_identifier('ecookbook')] = 'test,main'
    ContactsSetting[:helpdesk_answer_from, Project.find_by_identifier('ecookbook')] = 'test@email.from'
    ContactsSetting[:helpdesk_send_notification, Project.find_by_identifier('ecookbook')] = 1
    issue = submit_email('new_issue_new_contact.eml', :issue => {:project => 'ecookbook'})
    assert_equal Issue, issue.class
    assert !issue.new_record?
    issue.reload
    assert_equal issue, Issue.find_by_subject('New support issue from email')
    contact = issue.contacts.first
    assert_equal "New", contact.first_name
    assert_equal "Customer-Name", contact.last_name
    assert contact.tag_list.include?('test')
    assert contact.tag_list.include?('main')
    assert_equal 'ecookbook', contact.project.identifier
    assert_equal "new_customer@somenet.foo", contact.email
    assert last_email.from.include?('test@email.from')
    assert last_email.to.include?(contact.emails.first)
    assert !last_email.body.blank?
  end
  
  test "Should add contact with bad name" do
    ActionMailer::Base.deliveries.clear
    # This email contains: 'Project: onlinestore'
    ContactsSetting[:helpdesk_answer_from, Project.find_by_identifier('ecookbook')] = 'test@email.from'
    ContactsSetting[:helpdesk_send_notification, Project.find_by_identifier('ecookbook')] = 1
    issue = submit_email('new_contact_bad_name.eml', :issue => {:project => 'ecookbook'})
    assert_equal Issue, issue.class
    assert !issue.new_record?
    issue.reload
    assert_equal issue, Issue.find_by_subject('New support issue from email')
    contact = issue.contacts.first
    assert_equal "New customer", contact.first_name
    assert_equal "-", contact.last_name
    assert_equal "new_customer@somenet.foo", contact.email
    assert last_email.from.include?('test@email.from')
    assert last_email.to.include?(contact.emails.first)
    assert !last_email.body.blank?
  end
  
  test "Should not add contact" do
    ActionMailer::Base.deliveries.clear
    ContactsSetting[:helpdesk_is_not_create_contacts, Project.find_by_identifier('ecookbook')] = '1'
    issue = submit_email('new_issue_new_contact.eml', :issue => {:project => 'ecookbook'})
    assert_equal false, issue
  end

  test "Should not add contact from blacklist" do
    ActionMailer::Base.deliveries.clear
    ContactsSetting[:helpdesk_blacklist, Project.find_by_identifier('ecookbook')] = "new_customer@somenet.foo"
    issue = submit_email('new_issue_new_contact.eml', :issue => {:project => 'ecookbook'})
    assert_equal false, issue
  end

  test "Should not add contact from blacklist by regexp" do
    ActionMailer::Base.deliveries.clear
    ContactsSetting[:helpdesk_blacklist, Project.find_by_identifier('ecookbook')] = "new_.*\.foo"
    issue = submit_email('new_issue_new_contact.eml', :issue => {:project => 'ecookbook'})
    assert_equal false, issue
  end  

  test "Should add issue to contact" do
    ActionMailer::Base.deliveries.clear
    # This email contains: 'Project: onlinestore'
    ContactsSetting[:helpdesk_send_notification, Project.find_by_identifier('ecookbook')] = 1
    issue = submit_email('new_issue_to_contact.eml', :issue => {:project => 'ecookbook'})
    assert_equal Issue, issue.class
    assert !issue.new_record?
    issue.reload
    assert_equal issue, Issue.find_by_subject('New support issue to Ivan')
    contact = issue.contacts.first
    assert_equal "Ivan", contact.first_name
    assert last_email.to.include?(contact.emails.first)

  end
  
  test "Should attach mail to issue" do
    ActionMailer::Base.deliveries.clear
    # This email contains: 'Project: onlinestore'
    ContactsSetting[:helpdesk_send_notification, Project.find_by_identifier('ecookbook')] = 1
    ContactsSetting[:helpdesk_save_as_attachment, Project.find_by_identifier('ecookbook')] = 1
    issue = submit_email('new_issue_new_contact.eml', :issue => {:project => 'ecookbook'})
    assert_equal Issue, issue.class
    assert !issue.new_record?
    issue.reload
    assert_equal "message.eml", issue.attachments.last.filename
    assert issue.attachments.last.filesize > 0

  end
  
  
  test "Should add issue to contact with params" do
    ActionMailer::Base.deliveries.clear
    # This email contains: 'Project: onlinestore'
    issue = submit_email('new_issue_to_contact.eml', 
          :issue => {:project => 'ecookbook', 
                     :priority => 'Urgent',
                     :status => 'Resolved', 
                     :tracker => 'Support request', 
                     :due_date => '2011-12-12', 
                     :assigned_to => 'jsmith'})
    assert_equal Issue, issue.class
    assert !issue.new_record?
    issue.reload
    assert_equal issue, Issue.find_by_subject('New support issue to Ivan')
    assert_equal 'Urgent', issue.priority.name
    # assert_equal 'Assigned', issue.status.name
    assert_equal 'Support request', issue.tracker.name
    assert_equal 'jsmith', issue.assigned_to.login
    assert_equal '2011.12.12'.to_date, issue.due_date
    contact = issue.contacts.first
    assert_equal "Ivan", contact.first_name
    assert last_email.to.include?(contact.emails.first)

  end
  
  test "Should reply to issue to contact" do
    ActionMailer::Base.deliveries.clear
    
    issue = Issue.find(5)
    contact = Contact.find(1)
    issue.contacts << contact
    issue.save

    assert_not_equal 'Feedback', issue.status.name 
    
    journal = submit_email('reply_from_contact.eml', :issue => {:project => 'ecookbook'}, :reopen_status => 'Feedback')
    assert_equal Journal, journal.class
    assert !journal.new_record?

    journal.reload
    issue.reload
    contact = journal.issue.contacts.first
    
    assert_equal 1, journal.contacts.first.id
    assert_equal issue.contacts, journal.issue.contacts
    assert_equal issue, journal.issue
    assert_equal 'subproject1', journal.issue.project.identifier
    assert_equal "Ivan", contact.first_name
    assert_equal 'Feedback', issue.status.name

  end
  
  test "Should reply to issue to contact with attachment" do
    ActionMailer::Base.deliveries.clear
    
    issue = Issue.find(5)
    contact = Contact.find(1)
    issue.contacts << contact
    issue.save

    assert_not_equal 'Feedback', issue.status.name
    
    # This email contains: 'Project: onlinestore'
    journal = submit_email('reply_with_attachment.eml', :issue => {:project => 'ecookbook'}, :reopen_status => 'Feedback')
    assert_equal Journal, journal.class
    assert !journal.new_record?

    journal.reload
    issue.reload
    contact = journal.issue.contacts.first
    
    assert_equal 1, journal.contacts.first.id
    assert_equal issue.contacts, journal.issue.contacts
    assert_equal issue, journal.issue
    assert_equal 'subproject1', journal.issue.project.identifier
    assert_equal "Ivan", contact.first_name
    assert_equal 'Feedback', issue.status.name
    attachment = issue.attachments.find_by_filename("Paella.jpg") 
    assert_not_nil attachment
    assert File.size?(attachment.diskfile) > 0
    assert File.size?(issue.attachments.last.diskfile) > 0

  end  
  
  test "Should attach email to reply" do
    ActionMailer::Base.deliveries.clear
    
    issue = Issue.find(5)
    contact = Contact.find(1)
    issue.contacts << contact
    issue.save

    assert_not_equal 'Feedback', issue.status.name 
    
    ContactsSetting[:helpdesk_save_as_attachment, Project.find_by_identifier('ecookbook')] = 1
    journal = submit_email('reply_from_contact.eml', :issue => {:project => 'ecookbook'}, :reopen_status => 'Feedback')
    assert_equal Journal, journal.class
    assert !journal.new_record?

    journal.reload
    issue.reload
    contact = journal.issue.contacts.first
    
    assert_equal 1, journal.contacts.first.id
    assert_equal issue.contacts, journal.issue.contacts
    assert_equal issue, journal.issue
    assert_equal "reply-#{DateTime.now.strftime('%d.%m.%y-%H.%M.%S')}.eml", journal.contact_journals.first.attachments.last.filename
    assert File.size?(journal.contact_journals.first.attachments.last.diskfile) > 0
    
  end
  
  
  test "Should deliver received request confirmation" do
    issue = Issue.find(4)
    contact = Contact.find(1)
    assert ContactsHelpdeskMailer.deliver_received_request_confirmation(contact, issue)
    assert last_email.to.include?(contact.emails.first)
    assert !last_email.body.blank?
  end

  test "Should deliver response" do
    issue = Issue.find(1)
    contact = Contact.find(1)
    assert ContactsHelpdeskMailer.deliver_issue_response(contact, issue.journals.last, params = {})
    assert last_email.to.include?(contact.emails.first)
    assert last_email.subject.include?("[#{issue.tracker} ##{issue.id}]")
  end

  test "Should send from changed address" do
    issue = Issue.find(1)
    contact = Contact.find(1)
    ContactsSetting[:helpdesk_answer_from, issue.project] = "newfrom@mail.com"
    
    assert ContactsHelpdeskMailer.deliver_issue_response(contact, issue.journals.last, params = {})
    assert last_email.to.include?(contact.emails.first)
    assert last_email.subject.include?("[#{issue.tracker} ##{issue.id}]")
    assert_equal "newfrom@mail.com", last_email.from.to_s
  end

  private

  def submit_email(filename, options={})
    raw = IO.read(File.join(FIXTURES_PATH, filename))
    ContactsHelpdeskMailer.receive(raw, options)
  end

  def last_email
    mail = ActionMailer::Base.deliveries.last
    assert_not_nil mail
    mail
  end
  
end
