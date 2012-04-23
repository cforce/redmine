class ContactsHelpdeskMailer < MailHandler
  include ContactsHelpdeskMailerHelper
  
  attr_reader :contact, :user, :email
  
  def self.default_url_options
    h = Setting.host_name
    h = h.to_s.gsub(%r{\/.*$}, '') unless Redmine::Utils.relative_url_root.blank?
    { :host => h, :protocol => Setting.protocol }
  end
  
  def issue_response(contact, journal, params)
    response_message = ''
    response_message << apply_macro(HelpdeskSettings[:helpdesk_emails_header, journal.issue.project], contact, journal.issue) + "\n\n" unless HelpdeskSettings[:helpdesk_emails_header, journal.issue.project].blank?
    response_message << apply_macro(journal.notes, contact, journal.issue, journal)
    response_message << "\n\n" + apply_macro(HelpdeskSettings[:helpdesk_emails_footer, journal.issue.project], contact, journal.issue)  unless HelpdeskSettings[:helpdesk_emails_footer, journal.issue.project].blank?
    response_message << ''
    
    raise MissingInformation.new("Contact #{contact.name} should have mail") if response_message.blank? || contact.email.blank?
    # return false if response_message.blank? || contact.email.blank?
    
    recipients contact.emails.first
    from HelpdeskSettings[:helpdesk_answer_from, journal.issue.project] || User.current.mail 
    subject journal.issue.subject + " [#{journal.issue.tracker} ##{journal.issue.id}]"
    content_type "multipart/mixed"

    headers 'X-Redmine-Issue-ID' => journal.issue.id
    
    email_styles = '<style type="text/css">' + HelpdeskSettings[:helpdesk_helpdesk_css, journal.issue.project].to_s + '</style> '

    part "multipart/alternative" do |alternative|
      alternative.part :content_type => "text/plain", :body => response_message
      alternative.part :content_type => "text/html", :body => email_styles + textile(response_message)
    end  
    
    params[:attachments].each_value do |mail_attachment|
      unless mail_attachment['file'].blank?
        mail_attachment['file'].rewind
        attachment :content_type => mail_attachment['file'].content_type, :body => mail_attachment['file'].read, :filename => mail_attachment['file'].original_filename
        mail_attachment['file'].rewind
      end  
    end unless params[:attachments].blank?
    
  end
  
  def self.receive(email, options={})
    @@helpdesk_mailer_options = options.dup
    super email
  end
  
  # Processes incoming emails
  # Returns the created object (eg. an issue, a message) or false
  def receive(email)
    @email = email
    sender_email = email.from.to_a.first.to_s.strip
    # Ignore emails received from the application emission address to avoid hell cycles
    if sender_email.downcase == Setting.mail_from.to_s.strip.downcase
      logger.info  "MailHandler: ignoring email from Redmine emission address [#{sender_email}]" if logger && logger.info
      return false
    end
    @user = (HelpdeskSettings[:helpdesk_assign_author, target_project].to_i > 0 && User.find_by_mail(sender_email)) || User.anonymous
    @contact = contact_from_email(email) 
    User.current = @user

    if @contact
      logger.info "MailHandler: [#{@contact.name}] contact created" if logger && logger.info
    else
      logger.error "MailHandler: could not create contact for [#{sender_email}]" if logger && logger.error
      return false
    end

    if !check_blacklist?(email)
      logger.info "MailHandler: Email #{sender_email} ignored because in blacklist" if logger && logger.info
      return false
    end 
    
    dispatch
  end
  
  def self.check_imap(imap_options={}, options={})
    require 'net/imap'
    require 'openssl'
    
    host = imap_options[:host] || '127.0.0.1'
    port = imap_options[:port] || '143'
    ssl = !imap_options[:ssl].nil?
    folder = imap_options[:folder] || 'INBOX'
    
    imap = Net::IMAP.new(host, port, ssl)        
    imap.login(imap_options[:username], imap_options[:password]) unless imap_options[:username].nil?
    imap.select(folder)
    msg_count = 0
    imap.search(['NOT', 'SEEN']).each do |message_id|
      msg = imap.fetch(message_id,'RFC822')[0].attr['RFC822']
      logger.debug "Receiving message #{message_id}" if logger && logger.debug?
      msg_count += 1
      if ContactsHelpdeskMailer.receive(msg, options)
        logger.debug "Message #{message_id} successfully received" if logger && logger.debug?
        if imap_options[:move_on_success]
          imap.copy(message_id, imap_options[:move_on_success])
        end
        imap.store(message_id, "+FLAGS", [:Seen, :Deleted])
      else
        logger.debug "Message #{message_id} can not be processed" if logger && logger.debug?
        imap.store(message_id, "+FLAGS", [:Seen])
        if imap_options[:move_on_failure]
          imap.copy(message_id, imap_options[:move_on_failure])
          imap.store(message_id, "+FLAGS", [:Deleted])
        end
      end
    end
    imap.expunge
    msg_count
  end
  
  def self.check_pop3(pop_options={}, options={})
    require 'net/pop'
    
    host = pop_options[:host] || '127.0.0.1'
    port = pop_options[:port] || '110'
    apop = (pop_options[:apop].to_s == '1')
    delete_unprocessed = (pop_options[:delete_unprocessed].to_s == '1')

    pop = Net::POP3.APOP(apop).new(host,port)
    logger.debug "Connecting to #{host}..." if logger && logger.debug?
    msg_count = 0
    pop.start(pop_options[:username], pop_options[:password]) do |pop_session|
      if pop_session.mails.empty?
        logger.debug "No email to process" if logger && logger.debug?
      else
        logger.debug "#{pop_session.mails.size} email(s) to process..." if logger && logger.debug?
        pop_session.each_mail do |msg|
          msg_count += 1
          message = msg.pop
          message_id = (message =~ /^Message-ID: (.*)/ ? $1 : '').strip
          if ContactsHelpdeskMailer.receive(message, options)
            msg.delete
            logger.debug "--> Message #{message_id} processed and deleted from the server" if logger && logger.debug?
          else
            if delete_unprocessed
              msg.delete
              logger.debug "--> Message #{message_id} NOT processed and deleted from the server" if logger && logger.debug?
            else
              logger.debug "--> Message #{message_id} NOT processed and left on the server" if logger && logger.debug?
            end
          end
        end
      end
    end
    msg_count
  end

  def self.check_project(project_id)
    msg_count = 0
    unless Project.find_by_id(project_id).blank? || HelpdeskSettings[:helpdesk_protocol, project_id].blank? 
      case HelpdeskSettings[:helpdesk_protocol, project_id]
      when "gmail"
        protocol = "imap"
        host = "imap.gmail.com"
        port = "993"
        ssl = "1"
      when "yahoo"
        protocol = "imap"
        host = "imap.mail.yahoo.com"
        port = "993"
        ssl = "1"
      else
        protocol = HelpdeskSettings[:helpdesk_protocol, project_id]
        host = HelpdeskSettings[:helpdesk_host, project_id]
        port = HelpdeskSettings[:helpdesk_port, project_id]
        ssl =  HelpdeskSettings[:helpdesk_use_ssl, project_id] != "1" ? nil : "1"
      end

      mail_options  = {:host => host,
                      :port => port,
                      :ssl => ssl,
                      :apop => HelpdeskSettings[:helpdesk_apop, project_id],
                      :username => HelpdeskSettings[:helpdesk_username, project_id],
                      :password => HelpdeskSettings[:helpdesk_password, project_id],
                      :folder => HelpdeskSettings[:helpdesk_imap_folder, project_id],            
                      :move_on_success => HelpdeskSettings[:helpdesk_move_on_success, project_id],            
                      :move_on_failure => HelpdeskSettings[:helpdesk_move_on_failure, project_id],
                      :delete_unprocessed => HelpdeskSettings[:helpdesk_delete_unprocessed, project_id].to_i > 0
                      }              
      options = { :issue => {} }
      options[:issue][:project] = project_id
      options[:issue][:status_id] = HelpdeskSettings[:helpdesk_new_status, project_id]
      options[:issue][:assigned_to_id] = HelpdeskSettings[:helpdesk_assigned_to, project_id]
      options[:issue][:tracker_id] = HelpdeskSettings[:helpdesk_tracker, project_id]
      options[:issue][:priority_id] = HelpdeskSettings[:helpdesk_issue_priority, project_id]
      options[:issue][:due_date] = HelpdeskSettings[:helpdesk_issue_due_date, project_id]
      options[:issue][:reopen_status_id] = HelpdeskSettings[:helpdesk_reopen_status, project_id]
      
      case HelpdeskSettings[:helpdesk_protocol, project_id]
      when "pop3" then
        msg_count = ContactsHelpdeskMailer.check_pop3(mail_options, options)                
      when "imap", "gmail", "yahoo" then
        msg_count = ContactsHelpdeskMailer.check_imap(mail_options, options)                
      end 
    end
    
    msg_count
  end  

  private

  def received_request_confirmation(contact, issue)
    recipients contact.emails.first
    from HelpdeskSettings[:helpdesk_answer_from, target_project] || User.current.mail 
    subject apply_macro(HelpdeskSettings[:helpdesk_first_answer_subject, target_project], contact, issue)
    headers 'X-Redmine-Issue-ID' => issue.id
    
    confirmation_body = apply_macro(HelpdeskSettings[:helpdesk_first_answer_template, target_project], contact, issue)

    content_type "multipart/alternative"
    
    email_styles = '<style type="text/css">' + HelpdeskSettings[:helpdesk_helpdesk_css, target_project].to_s + '</style> '

    part :content_type => "text/plain", :body => confirmation_body
    part :content_type => "text/html", :body => email_styles + textile(confirmation_body)
    
    logger.info  "MailHandler: Sending confirmation" if logger && logger.info
    

  end
  
  def dispatch
    headers = [email.in_reply_to, email.references].flatten.compact
    if headers.detect {|h| h.to_s =~ MESSAGE_ID_RE}
      klass, object_id = $1, $2.to_i
      method_name = "receive_#{klass}_reply"
      if self.class.private_instance_methods.collect(&:to_s).include?(method_name)
        send method_name, object_id
      else
        # ignoring it
      end
    elsif m = email.subject.match(ISSUE_REPLY_SUBJECT_RE)
      receive_issue_reply(m[1].to_i)
    else
      dispatch_to_default
    end
  rescue ActiveRecord::RecordInvalid => e
    # TODO: send a email to the user
    logger.error e.message if logger
    false
  rescue MissingInformation => e
    logger.error "MailHandler: missing information from #{user}: #{e.message}" if logger
    false
  rescue UnauthorizedAction => e
    logger.error "MailHandler: unauthorized attempt from #{user}" if logger
    false
  end

  def dispatch_to_default
    receive_issue
  end
  
  def target_project
    @target_project ||= Project.find(get_keyword(:project))
    raise MissingInformation.new('Unable to determine target project') if @target_project.nil?
    @target_project
  end
  
  # Returns a Hash of issue attributes extracted from keywords in the email body
  def helpdesk_issue_attributes_from_keywords(issue)
    assigned_to = ((k = get_keyword(:assigned_to_id, :override => true)) && User.find_by_id(k)) || ((k = get_keyword(:assigned_to, :override => true)) && find_user_from_keyword(k))
    
    # assigned_to = nil if assigned_to && !issue.assignable_users.include?(assigned_to)

    attrs = {
      'tracker_id' => ((k = get_keyword(:tracker)) && issue.project.trackers.named(k).first.try(:id)) || ((k = get_keyword(:tracker_id)) && issue.project.trackers.find(k).try(:id)),
      'status_id' =>  ((k = get_keyword(:status)) && IssueStatus.named(k).first.try(:id) ) || ((k = get_keyword(:status_id)) && IssueStatus.find(k).try(:id)),
      'priority_id' => ((k = get_keyword(:priority)) && IssuePriority.named(k).first.try(:id)) || ((k = get_keyword(:priority_id)) && IssuePriority.find(k).try(:id)),
      'category_id' => (k = get_keyword(:category)) && issue.project.issue_categories.named(k).first.try(:id),
      'assigned_to_id' => assigned_to.try(:id),
      'fixed_version_id' => (k = get_keyword(:fixed_version, :override => true)) && issue.project.shared_versions.named(k).first.try(:id),
      'start_date' => get_keyword(:start_date, :override => true, :format => '\d{4}-\d{2}-\d{2}'),
      'due_date' => get_keyword(:due_date, :override => true, :format => '\d{4}-\d{2}-\d{2}'),
      'estimated_hours' => get_keyword(:estimated_hours, :override => true),
      'done_ratio' => get_keyword(:done_ratio, :override => true, :format => '(\d|10)?0')
    }.delete_if {|k, v| v.blank? }

    if issue.new_record? && attrs['tracker_id'].nil?
      attrs['tracker_id'] = issue.project.trackers.find(:first).try(:id)
    end

    attrs
  end

  # Creates a new issue
  def receive_issue
    project = target_project
    
    # check permission
    issue = Issue.new(:author => user, :project => project)
    issue.safe_attributes = helpdesk_issue_attributes_from_keywords(issue)
    issue.safe_attributes = {'custom_field_values' => custom_field_values_from_keywords(issue)}
    issue.subject = email.subject.to_s.chomp[0,255]
    issue.subject = '(no subject)' if issue.subject.blank?
    issue.description = cleaned_up_text_body
    # add To and Cc as watchers before saving so the watchers can reply to Redmine
    issue.contacts << contact
    issue.save!
    
    save_email_as_attachment(issue) if HelpdeskSettings[:helpdesk_save_as_attachment, target_project].to_i > 0

    contact.notes << ContactNote.new(:content => "*#{issue.subject}* [#{issue.tracker.name} - ##{issue.id}]\n\n" + issue.description, 
                              :type_id => Note.note_types[:email],
                              :author_id => issue.author_id)
    contact.save!
    add_attachments(issue)
    ContactsHelpdeskMailer.deliver_received_request_confirmation(contact, issue) if HelpdeskSettings[:helpdesk_send_notification, project].to_i > 0
    logger.info "MailHandler: issue ##{issue.id} created by #{user} for #{contact.name}" if logger && logger.info
    issue
  end

  # Adds a note to an existing issue
  def receive_issue_reply(issue_id)
    issue = Issue.find_by_id(issue_id)
    return unless issue
    # check permission
    # if lifetime expaired create new issue
    if (HelpdeskSettings[:helpdesk_lifetime, target_project].to_i > 0) && issue.journals && issue.journals.last && ((Date.today) - issue.journals.last.created_on.to_date > HelpdeskSettings[:helpdesk_lifetime, target_project].to_i)
      email.subject = email.subject.to_s.gsub(ISSUE_REPLY_SUBJECT_RE, '')
      return receive_issue
    end
    
    # @@helpdesk_mailer_options[:issue].clear

    journal = issue.init_journal(user)
    # issue.safe_attributes = issue_attributes_from_keywords(issue)
    # issue.safe_attributes = {'custom_field_values' => custom_field_values_from_keywords(issue)}

    issue.status_id = ((k = @@helpdesk_mailer_options[:reopen_status]) && IssueStatus.named(k).first.try(:id) ) || ((k = get_keyword(:reopen_status_id)) && IssueStatus.find_by_id(k).try(:id))

    journal.notes = cleaned_up_text_body
    
    contact_journal = ContactJournal.create(:email => email.from.to_s,
                                            :is_incoming => true,
                                            :contact => contact,
                                            :journal => journal)

    add_attachments(issue)
                          
    if HelpdeskSettings[:helpdesk_save_as_attachment, target_project].to_i > 0                      
      eml_attachment = save_email_as_attachment(contact_journal, "reply-#{DateTime.now.strftime('%d.%m.%y-%H.%M.%S')}.eml")
    end
    
    issue.save!
    logger.info "MailHandler: issue ##{issue.id} updated by #{user}" if logger && logger.info
    journal
  end

  # Reply will be added to the issue
  def receive_journal_reply(journal_id)
    journal = Journal.find_by_id(journal_id)
    if journal && journal.journalized_type == 'Issue'
      receive_issue_reply(journal.journalized_id)
    end
  end  

  def get_keyword(attr, options={})
    @keywords ||= {}
    if @keywords.has_key?(attr)
      @keywords[attr]
    else
      @keywords[attr] = @@helpdesk_mailer_options[:issue][attr]
    end
  end
  
  def find_user_from_keyword(keyword)
    user ||= User.find_by_mail(keyword)
    user ||= User.find_by_login(keyword)
    if user.nil? && keyword.match(/ /)
      firstname, lastname = *(keyword.split) # "First Last Throwaway"
      user ||= User.find_by_firstname_and_lastname(firstname, lastname)
    end
    user
  end
  
  def check_blacklist?(email)
    return true if HelpdeskSettings[:helpdesk_blacklist, target_project.id].blank?
    addr = email.from_addrs.to_a.first
    from_addr = (addr && !addr.spec.blank?) ? addr.spec : email.header["from"].inspect.match(/[-A-z0-9.]+@[-A-z0-9.]+/).to_s 
    cond = "(" + HelpdeskSettings[:helpdesk_blacklist, target_project.id].split("\n").map{|u| u.strip}.join('|') + ")"
    !from_addr.match(cond)
  end

  # Get or create contact for the +email+ sender
  def contact_from_email(email)
    addr = email.from_addrs.to_a.first
  
    from_addr = (addr && !addr.spec.blank?) ? addr.spec : email.header["from"].inspect.match(/[-A-z0-9.]+@[-A-z0-9.]+/).to_s 
    from_name = (addr && !addr.spec.blank?) ? addr.name.to_s : ""
    from_company = (addr && !addr.spec.blank?) ? addr.domain.humanize : from_addr.gsub(/.*@/, '').humanize
    
    if !from_addr.blank?
      
      contacts = Contact.find_by_emails(from_addr.to_a)
      if !contacts.blank?
        # if HelpdeskSettings[:helpdesk_add_contact_to_project, target_project].to_i > 0
        contacts.first.projects << target_project 
        return contacts.first
      end  
      
      unless HelpdeskSettings[:helpdesk_is_not_create_contacts, target_project].to_i > 0
        contact = Contact.new
        contact.email = from_addr
        contact.projects << target_project
        names = from_name.blank? ? from_addr.gsub(/@.*$/, '').split('.').map{|e| e.humanize} : TMail::Unquoter.unquote_and_convert_to(from_name, 'UTF-8').split
        contact.first_name = names.shift
        contact.last_name = names.join(' ')
        contact.last_name = '-' if contact.last_name.blank?
        contact.tag_list = HelpdeskSettings[:helpdesk_created_contact_tag, target_project] if HelpdeskSettings[:helpdesk_created_contact_tag, target_project]
        contact.company = from_company
      end
    end 
    
    contact && contact.save ? contact : nil 
  end

  def apply_macro(text, contact, issue, journal=nil)
    return '' if text.blank?
    
    text = text.gsub(/%%NAME%%/, contact.first_name)
    text = text.gsub(/%%FULL_NAME%%/, contact.name)
    text = text.gsub(/%%COMPANY%%/, contact.company) if contact.company
    text = text.gsub(/%%LAST_NAME%%/, contact.last_name.blank? ? "" : contact.last_name) 
    text = text.gsub(/%%MIDDLE_NAME%%/, contact.middle_name.blank? ? "" : contact.middle_name) 
    text = text.gsub(/%%DATE%%/, Date.today.to_s)
    text = text.gsub(/%%ASSIGNEE%%/, issue.assigned_to.blank? ? "" : issue.assigned_to.name) 
    text = text.gsub(/%%ISSUE_ID%%/, issue.id.to_s) if issue.id
    text = text.gsub(/%%ISSUE_TRACKER%%/, issue.tracker.name) if issue.tracker
    text = text.gsub(/%%PROJECT%%/, issue.project.name) if issue.project
    text = text.gsub(/%%SUBJECT%%/, issue.subject) if issue.subject
    text = text.gsub(/%%UPDATER%%/, journal.user.blank? ? "" : journal.user.name) if journal

    
    issue.custom_field_values.each do |value|
      text = text.gsub(/%%#{value.custom_field.name}%%/, value.value.to_s)
  	end    
    
    text
  end
  
  # Returns a Hash of issue custom field values extracted from keywords in the email body
  def custom_field_values_from_keywords(customized)
    customized.custom_field_values.inject({}) do |h, v|
      if value = get_keyword(v.custom_field.name, :override => true)
        h[v.custom_field.id.to_s] = value
      end
      h
    end
  end
  
  def save_email_as_attachment(container, filename="message.eml")
    eml_file = TMail::Attachment.new(email.port.to_s)
    eml_file.original_filename = filename
    eml_file.content_type = "message/rfc822"
    eml_file.rewind
    eml_attachment =  Attachment.create(:container => container,
                                           :file => eml_file,
                                           :author => user,
                                           :content_type => eml_file.content_type)
    eml_file.rewind
    container.attachments << eml_attachment
    eml_attachment
  end  
  
  def logger
    RAILS_DEFAULT_LOGGER
  end
  
end
