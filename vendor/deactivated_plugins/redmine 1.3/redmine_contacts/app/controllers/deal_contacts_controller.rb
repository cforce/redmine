class DealContactsController < ApplicationController
  unloadable    
  
  before_filter :find_project_by_project_id, :authorize
  before_filter :find_contact, :only => :delete    
  before_filter :find_deal
	
	helper :deals
	
  def add    
    @show_form = "true"    
    
    if params[:contact_id] && request.post? then    
      find_contact  
      if !@deal.all_contacts.include?(@contact)
        @deal.related_contacts << @contact
        @deal.save
      end  
    end
    
    respond_to do |format|
      format.html { redirect_to :back }  
      format.js do
        render :update do |page|   
          page.replace_html 'deal_contacts', :partial => 'deal_contacts/contacts'
        end
      end
    end
  end  

  def delete 
    @deal.related_contacts.delete(@contact)
    respond_to do |format|
      format.html { redirect_to :back }
      format.js do
        render :update do |page|
          page.replace_html 'deal_contacts', :partial => 'deal_contacts/contacts'
        end
      end
    end    
  end


	private
  def find_contact 
    @contact = Contact.find(params[:contact_id]) 
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_deal 
    @deal = Deal.find(params[:deal_id]) 
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end