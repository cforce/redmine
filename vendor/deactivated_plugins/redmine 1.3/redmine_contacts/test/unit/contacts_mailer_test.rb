require File.dirname(__FILE__) + '/../test_helper'  

class ContactsMailerTest < ActiveSupport::TestCase
  fixtures :users, :projects,
                   :enabled_modules,
                   :roles,
                   :members,
                   :member_roles,
                   :users,
                   :issues,
                   :issue_statuses,
                   :workflows,
                   :trackers,
                   :projects_trackers,
                   :versions,
                   :enumerations,
                   :issue_categories,
                   :custom_fields,
                   :custom_fields_trackers,
                   :custom_fields_projects,
                   :boards,
                   :messages,
                   :contacts,
                   :contacts_projects,
                   :deals,
                   :notes,
                   :tags,
                   :taggings

  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures/contacts_mailer'

  def setup
    RedmineContacts::TestCase.prepare
    
    ActionMailer::Base.deliveries.clear
    Setting.notified_events = Redmine::Notifiable.all.collect(&:name)
  end


  test "Should add contact note from to" do
    ActionMailer::Base.deliveries.clear
    # This email contains: 'Project: onlinestore'
    note = submit_email('new_note.eml').first
    assert note.is_a?(Note)
    assert !note.new_record?
    note.reload
    assert_equal Contact, note.source.class
    assert_equal "New note from email", note.subject
    assert_equal User.find_by_login('admin'), note.author
    assert_equal Contact.find(1).id, note.source_id
  end

  test "Should add contact note from ID in to" do
    ActionMailer::Base.deliveries.clear
    # This email contains: 'Project: onlinestore'
    note = submit_email('new_note_by_id.eml').first
    assert note.is_a?(Note)
    assert !note.new_record?
    note.reload
    assert_equal Contact, note.source.class
    assert_equal "New note from email", note.subject
    assert_equal User.find_by_login('admin'), note.author
    assert_equal Contact.find(1).id, note.source_id
  end

  test "Should add deal note from ID in to" do
    ActionMailer::Base.deliveries.clear
    # This email contains: 'Project: onlinestore'
    note = submit_email('new_deal_note_by_id.eml').first
    assert note.is_a?(Note)
    assert !note.new_record?
    note.reload
    assert_equal Deal, note.source.class
    assert_equal "New note from email", note.subject
    assert_equal User.find_by_login('admin'), note.author
    assert_equal Deal.find(1).id, note.source_id
  end

  
  test "Should add contact note from forwarded" do
    ActionMailer::Base.deliveries.clear
    # This email contains: 'Project: onlinestore'
    note = submit_email('fwd_new_note_plain.eml').first
    assert note.is_a?(Note)
    assert !note.new_record?
    note.reload
    assert_equal Contact, note.source.class
    assert_equal "New note from forwarded email", note.subject
    assert_equal "From: \"Marat Aminov\" marat@mail.ru\n", note.content.lines.collect[1]
    assert_equal User.find_by_login('admin'), note.author
    assert_equal Contact.find(2).id, note.source_id
  end

  test "Should add contact note from forwarded html" do
    ActionMailer::Base.deliveries.clear
    # This email contains: 'Project: onlinestore'
    note = submit_email('fwd_new_note_html.eml').first
    assert note.is_a?(Note)
    assert !note.new_record?
    note.reload
    assert_equal Contact, note.source.class
    assert_equal "New note from forwarded html email", note.subject
    assert_equal "From: Marat Aminov <marat@mail.com>\n", note.content.collect[2]
    assert_equal User.find_by_login('admin'), note.author
    assert_equal Contact.find(2).id, note.source_id
  end

  
  test "Should not add contact note from deny user to" do
    ActionMailer::Base.deliveries.clear
    # This email contains: 'Project: onlinestore'
    assert !submit_email('new_deny_note.eml')
    # assert note.is_a?(Note)
    # assert !note.new_record?
    # note.reload
    # assert_equal Contact, note.source.class
    # assert_equal "New note from email", note.subject
    # assert_equal User.find_by_login('admin'), note.author
    # assert_equal Contact.find(1).id, note.source_id
  end
  

  private

  def submit_email(filename, options={})
    raw = IO.read(File.join(FIXTURES_PATH, filename))
    ContactsMailer.receive(raw, options)
  end

end
