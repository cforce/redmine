module RedmineContactsHelpdesk
  module Patches    
    
    module IssuesControllerPatch
      
      module InstanceMethods    

        def send_helpdesk_response  
          return unless @project.module_enabled?(:contacts_helpdesk)
          @issue.contacts.each do |contact|
            if params[:is_send_mail] && contact && @issue.current_journal && !@notes.blank? 
              begin
                ContactsHelpdeskMailer.deliver_issue_response(contact, @issue.current_journal, params) 
              
                ContactJournal.create(:email => contact.emails.first,
                                      :is_incoming => false,
                                      :contact => contact,
                                      :journal => @issue.current_journal)
                                      
                flash[:notice].blank? ? flash[:notice] = l(:notice_email_sent, "<span class='icon icon-email'>" + contact.emails.first  + "</span>") : flash[:notice] << " " + l(:notice_email_sent, "<span class='icon icon-email'>" + contact.emails.first  + "</span>")
              rescue Exception => e
                flash[:error].blank? ? flash[:error] = e.message : flash[:error] << " " + e.message
              end    
            end
          end  
        end 
        
      end
  
      def self.included(base) # :nodoc: 
        base.send(:include, InstanceMethods)
        
        base.class_eval do 
          unloadable   
          after_filter :send_helpdesk_response, :only => :update 
          
        end  
      end
        
    end
    
  end
end  

Dispatcher.to_prepare do  

  unless IssuesController.included_modules.include?(RedmineContactsHelpdesk::Patches::IssuesControllerPatch)
    IssuesController.send(:include, RedmineContactsHelpdesk::Patches::IssuesControllerPatch)
  end

end