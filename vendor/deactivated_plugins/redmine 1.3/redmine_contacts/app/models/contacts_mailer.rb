class ContactsMailer < ActionMailer::Base
  include Redmine::I18n

  class UnauthorizedAction < StandardError; end
  class MissingInformation < StandardError; end

  helper :application

  attr_reader :email, :user
  
  def self.default_url_options
    h = Setting.host_name
    h = h.to_s.gsub(%r{\/.*$}, '') unless Redmine::Utils.relative_url_root.blank?
    { :host => h, :protocol => Setting.protocol }
  end
  
  def bulk_mail(contact, params = {})
    raise l(:error_empty_email) if (contact.emails.empty? || params[:message].blank?)

    from params[:from] || User.current.mail
    recipients contact.emails.first
    bcc params[:bcc]
    subject params[:subject]  

    body :contact => contact, :params => params

    content_type "multipart/mixed"

    part "multipart/alternative" do |alternative|
      alternative.part :content_type => "text/plain", :body => render(:file => "bulk_mail.text.plain.rhtml", :body => body)
      alternative.part :content_type => "text/html", :body => render_message("bulk_mail.text.html.rhtml", body)
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
    @@contacts_mailer_options = options.dup
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
    @user = User.find_by_mail(sender_email) if sender_email.present?
    if @user.nil? || (@user && !@user.active?)
      logger.info   "MailHandler: ignoring email from unknown user [#{sender_email}]" if logger && logger.info
    end
    dispatch
  end
  
  def dispatch
    
    deal_id = email.to.to_s.match(/.+\+d([0-9]*)/).to_a[1] 
    if deal_id 
      deal = Deal.find_by_id(deal_id)
      if deal
        return [*receive_deal_note(deal_id)]
      end  
    end  
    
    contacts = []

    if contacts.blank? 
      contact_id = email.to.to_s.match(/.+\+c([0-9]*)/).to_a[1]
      contacts = Contact.find_all_by_id(contact_id)
    end
    
    if contacts.blank? 
      contacts = Contact.find_by_emails(email.to.to_a)
    end
    
    if contacts.blank? 
      # debugger
      from_key_words = get_keyword_locales(:label_mail_from)
      @plain_text_body = plain_text_body.gsub(/^>\s*/, '')
      full_address = plain_text_body.match(/^(#{from_key_words.join('|')})[ \s]*:[ \s]*(.+)\s*$/).to_a[2]
      
      email_address = full_address.match(/[\w,\.,\-,\+]+@.+\.\w{2,}/) if full_address
      contacts = Contact.find_by_emails(email_address.to_s.strip.to_a) if email_address
    end

    if contacts.blank?
      return false
    end
    
    raise MissingInformation if contacts.blank?
    
    result = []  
    contacts.each do |contact|
      result << receive_contact_note(contact.id)
    end 
    result
        
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
  

  # Receives a reply to a forum message
  def receive_contact_note(contact_id)
    contact = Contact.find_by_id(contact_id)
    note = nil
    # logger.error "MailHandler: receive_contact_note user: #{user}, 
    #               contact: #{contact.name}, 
    #               editable: #{contact.editable?(self.user)}, 
    #               current: #{User.current}"
    raise UnauthorizedAction unless contact.editable?(self.user)
    if contact
        note = ContactNote.new(:subject => email.subject.gsub(%r{^.*msg\d+\]}, '').strip,
                        :type_id => Note.note_types[:email],
                        :content => plain_text_body,
                        :created_on => email.date)
        note.author = self.user
        contact.notes << note
        add_attachments(note)
        logger.info note
        note.save
        contact.save
    end
    note
  end
  
  def receive_deal_note(deal_id)
    deal = Deal.find_by_id(deal_id)
    note = nil
    # logger.error "MailHandler: receive_contact_note user: #{user}, 
    #               contact: #{contact.name}, 
    #               editable: #{contact.editable?(self.user)}, 
    #               current: #{User.current}"
    raise UnauthorizedAction unless deal.editable?(self.user)
    if deal
        note = DealNote.new(:subject => email.subject.gsub(%r{^.*msg\d+\]}, '').strip,
                        :type_id => Note.note_types[:email],
                        :content => plain_text_body,
                        :created_on => email.date)
        note.author = self.user
        deal.notes << note
        add_attachments(note)
        logger.info note
        note.save
        deal.save
    end
    note
  end
  
  
  def self.check_imap(imap_options={}, options={})
    require 'net/imap'
    
    host = imap_options[:host] || '127.0.0.1'
    port = imap_options[:port] || '143'
    ssl = !imap_options[:ssl].nil?
    folder = imap_options[:folder] || 'INBOX'
    
    imap = Net::IMAP.new(host, port, ssl)        
    imap.login(imap_options[:username], imap_options[:password]) unless imap_options[:username].nil?
    imap.select(folder)
    imap.search(['NOT', 'SEEN']).each do |message_id|
      msg = imap.fetch(message_id,'RFC822')[0].attr['RFC822']
      logger.debug "Receiving message #{message_id}" if logger && logger.debug?
      if ContactsMailer.receive(msg, options)
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
  end
  
  def self.check_pop3(pop_options={}, options={})
    require 'net/pop'
    
    host = pop_options[:host] || '127.0.0.1'
    port = pop_options[:port] || '110'
    apop = (pop_options[:apop].to_s == '1')
    delete_unprocessed = (pop_options[:delete_unprocessed].to_s == '1')

    pop = Net::POP3.APOP(apop).new(host,port)
    logger.debug "Connecting to #{host}..." if logger && logger.debug?
    pop.start(pop_options[:username], pop_options[:password]) do |pop_session|
      if pop_session.mails.empty?
        logger.debug "No email to process" if logger && logger.debug?
      else
        logger.debug "#{pop_session.mails.size} email(s) to process..." if logger && logger.debug?
        pop_session.each_mail do |msg|
          message = msg.pop
          message_id = (message =~ /^Message-ID: (.*)/ ? $1 : '').strip
          if ContactsMailer.receive(message, options)
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
  end
  
  
  private
  
  # Destructively extracts the value for +attr+ in +text+
  # Returns nil if no matching keyword found
  def extract_keyword!(text, attr, format=nil)
    keys = [attr.to_s.humanize]
    if attr.is_a?(Symbol)
      keys << l("field_#{attr}", :default => '', :locale =>  user.language) if user && user.language.present?
      keys << l("field_#{attr}", :default => '', :locale =>  Setting.default_language) if Setting.default_language.present?
    end
    keys.reject! {|k| k.blank?}
    keys.collect! {|k| Regexp.escape(k)}
    format ||= '.+'
    text.gsub!(/^(#{keys.join('|')})[ \t]*:[ \t]*(#{format})\s*$/i, '') # /^(От:)[ \t]*:[ \t]*(.+)\s*$/i
    $2 && $2.strip
  end
  
  
  def add_attachments(obj)
    if email.has_attachments?
      email.attachments.each do |attachment|
        Attachment.create(:container => obj,
                          :file => attachment,
                          :author => user,
                          :content_type => attachment.content_type)
      end
    end
  end
  
  # Returns the text/plain part of the email
  # If not found (eg. HTML-only email), returns the body with tags removed
  def plain_text_body
    return @plain_text_body unless @plain_text_body.nil?
    parts = @email.parts.collect {|c| (c.respond_to?(:parts) && !c.parts.empty?) ? c.parts : c}.flatten
    if parts.empty?
      parts << @email
    end
    plain_text_part = parts.detect {|p| p.content_type == 'text/plain'}
    if plain_text_part.nil?
      # no text/plain part found, assuming html-only email
      # strip html tags and remove doctype directive
      @plain_text_body = ActionController::Base.helpers.strip_tags(@email.body.to_s)
      @plain_text_body.gsub! %r{^<!DOCTYPE .*$}, ''
    else
      @plain_text_body = plain_text_part.body.to_s
    end
    @plain_text_body.strip!
    @plain_text_body
  end
  
  def get_keyword_locales(keyword)
    I18n.available_locales.collect{|lc| l(keyword, :locale => lc)}.uniq
  end
  
  # Appends a Redmine header field (name is prepended with 'X-Redmine-')
  def redmine_headers(h)
    h.each { |k,v| headers["X-Redmine-#{k}"] = v }
  end

  def initialize_defaults(method_name)
    super
    # Common headers
    headers 'X-Mailer' => 'Redmine Contacts',
            'X-Redmine-Host' => Setting.host_name,
            'X-Redmine-Site' => Setting.app_title
  end
  
  def logger
    RAILS_DEFAULT_LOGGER
  end
  
  

end
