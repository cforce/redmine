class ContactsHelpdesksController < ApplicationController
  unloadable
  
  before_filter :find_project_by_project_id, :authorize, :except => [:email_note]
  
  accept_api_auth :email_note

  def save_settings
      if request.put?
        set_settings

        flash[:notice] = l(:notice_successful_update)
      end
      
      redirect_to :controller => 'projects', :action => 'settings', :tab => 'contacts_helpdesk', :id => @project
  end

  def show_original
    @attachment = Attachment.find(params[:id])

    @content = TMail::Unquoter.unquote_and_convert_to(TMail::Mail.load_from(@attachment.diskfile).header.collect{|k,v| "#{k} = #{v.to_s}"}.join("\n") , 'UTF-8') + "\n\n" +
               TMail::Mail.load_from(@attachment.diskfile).body  
    render "attachments/file"
  end
  
  def email_note
    # debugger
    raise Exception, "Param 'message' should be set" unless params[:message]

    @issue = Issue.find(params[:message][:issue_id])

    raise Exception, "Issue with ID: #{params[:message][:issue_id].to_i} should present and have contacts" unless @issue || @issue.contacts
    
    @journal = @issue.init_journal(User.current)
    @issue.status_id = params[:message][:status_id] if params[:message][:status_id].blank? && IssueStatus.find_by_id(params[:message][:status_id])
    @journal.notes = params[:message][:content]
    @issue.save!
    
    @issue.contacts.each do |contact|
      if ContactsHelpdeskMailer.deliver_issue_response(contact, @journal, params) 

        contact_journal = ContactJournal.create(:email => contact.emails.first,
                                                :is_incoming => false,
                                                :contact => contact,
                                                :journal => @journal)
      end                                             
    end  
    
    respond_to do |format|
      format.api { render :action => 'show', :status => :created } 
    end
    
  rescue Exception => e   
    respond_to do |format|
      format.api  { render :xml => e.message }
    end
  end  
  
  def test_connection
    require 'net/imap'
    require 'net/http'
    require 'net/pop'
    require 'openssl'
    
    flash[:notice] = l(:label_success)

    host = case params[:helpdesk_protocol] 
           when "gmail"
             "imap.gmail.com"
           when "yahoo"
             "imap.mail.yahoo.com"
           else
             params[:helpdesk_host]
           end    
           
    port = params[:helpdesk_port]
    ssl = !params[:helpdesk_use_ssl].nil?
    apop = !params[:helpdesk_apop].nil?
    username = params[:helpdesk_username]
    password = params[:helpdesk_password] 
    
    
    case params[:helpdesk_protocol] 
    when 'pop3'
      Net::POP3.auth_only(host, port, username, password, apop)
    when 'imap', 'gmail', 'yahoo'
      imap = Net::IMAP.new(host, port, ssl)  
      imap.login(username, password)
    end    
    
    respond_to do |format|
      format.js do 
        render :text => "<div class='flash notice'> #{l(:notice_successful_connection)} </div>"
      end     
      format.html {redirect_to :back}
    end
  rescue Exception => e
     flash[:notice] = e.message
     respond_to do |format|
       format.js do 
         render :text => "<div class='flash error'> #{l(:error_unable_to_connect, :value => e.message)}</div>"  
       end     
       format.html {redirect_to :back}
     end
    
  end
  
  def get_mail
    
    set_settings
    
    msg_count = ContactsHelpdeskMailer.check_project(@project.id)
    
    respond_to do |format|
      format.js do 
        render :text => "<div class='flash notice'> #{l(:label_helpdesk_get_mail_success, :count => msg_count)} </div>"
        flash.discard   
      end     
      format.html {redirect_to :back}
    end
  rescue Exception => e
     respond_to do |format|
       format.js do 
         render :text => "<div class='flash error'> Error: #{e.message} </div>"  
         flash.discard
       end     
       format.html {redirect_to :back}
     end
    
  end
  
  private
  
  def set_settings
    ContactsSetting[:helpdesk_answer_from, @project.id] = params[:helpdesk_answer_from]
    ContactsSetting[:helpdesk_send_notification, @project.id] = params[:helpdesk_send_notification]
    ContactsSetting[:helpdesk_is_not_create_contacts, @project.id] = params[:helpdesk_is_not_create_contacts]
    ContactsSetting[:helpdesk_created_contact_tag, @project.id] = params[:helpdesk_is_not_create_contacts].to_i > 0 ? '' : params[:helpdesk_created_contact_tag]
    ContactsSetting[:helpdesk_blacklist, @project.id] = params[:helpdesk_blacklist]
    ContactsSetting[:helpdesk_save_as_attachment, @project.id] = params[:helpdesk_save_as_attachment]
    ContactsSetting[:helpdesk_emails_header, @project.id] = params[:helpdesk_emails_header]
    ContactsSetting[:helpdesk_first_answer_subject, @project.id] = params[:helpdesk_first_answer_subject]
    ContactsSetting[:helpdesk_first_answer_template, @project.id] = params[:helpdesk_first_answer_template]
    ContactsSetting[:helpdesk_emails_footer, @project.id] = params[:helpdesk_emails_footer]
    ContactsSetting[:helpdesk_assign_author, @project.id] = params[:helpdesk_assign_author]
    ContactsSetting[:helpdesk_answered_status, @project.id] = params[:helpdesk_answered_status]
    ContactsSetting[:helpdesk_reopen_status, @project.id] = params[:helpdesk_reopen_status]
    ContactsSetting[:helpdesk_tracker, @project.id] = params[:helpdesk_tracker]
    ContactsSetting[:helpdesk_assigned_to, @project.id] = params[:helpdesk_assigned_to]
    ContactsSetting[:helpdesk_lifetime, @project.id] = params[:helpdesk_lifetime].to_i

    ContactsSetting[:helpdesk_protocol, @project.id] = params[:helpdesk_protocol]
    ContactsSetting[:helpdesk_host, @project.id] = params[:helpdesk_host]
    ContactsSetting[:helpdesk_port, @project.id] = params[:helpdesk_port]
    ContactsSetting[:helpdesk_password, @project.id] = params[:helpdesk_password]
    ContactsSetting[:helpdesk_username, @project.id] = params[:helpdesk_username]
    
    ContactsSetting[:helpdesk_use_ssl, @project.id] = params[:helpdesk_use_ssl]
    ContactsSetting[:helpdesk_imap_folder, @project.id] = params[:helpdesk_imap_folder]
    ContactsSetting[:helpdesk_move_on_success, @project.id] = params[:helpdesk_move_on_success]
    ContactsSetting[:helpdesk_move_on_failure, @project.id] = params[:helpdesk_move_on_failure]
    ContactsSetting[:helpdesk_apop, @project.id] = params[:helpdesk_apop]
    ContactsSetting[:helpdesk_delete_unprocessed, @project.id] = params[:helpdesk_delete_unprocessed]
  end
  
end
