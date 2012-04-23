class GoogleContactsController < ApplicationController
  unloadable
  
  before_filter :find_project_by_project_id, :authorize_for_import
  
  helper :custom_fields
  include GoogleContactsHelper
  
	def index
    # session.delete(:token)
	  if session[:token].blank?
	    redirect_to build_auth_url(url_for(:only_path => false, :controller => 'google_contacts', :action => 'google_authorize', :project_id => @project))
	  else  
	    maxresults = params[:show_all].blank? ? nil: 10000
  		@google_contacts = get_google_contacts(session[:token], {:q => params[:search], :"max-results" => maxresults}) || []
      respond_to do |format|   
        format.html 
        format.js { render :partial => "list", :layout => false } 
      end
		end
	end
	
	def drop_token
	  session.delete(:token)
	  redirect_to :back 
  end
	
	def import_contacts
	  if params[:ids].blank?
	    redirect_to :back 
	    return
    end
	  google_contacts = get_google_contacts(session[:token], :"max-results" => 10000) || []
	  google_contacts.each do |contact| 
	    if params[:ids].include?(contact[:id])
	      c = Contact.new
	      c.projects << @project
	      c.first_name = contact[:first_name]
	      c.last_name = contact[:last_name]
	      c.middle_name = contact[:middle_name]
	      c.phone = contact[:phones]
	      c.email = contact[:emails]
	      c.company = contact[:company]
	      c.job_title = contact[:job_title]
	      c.address = contact[:address]
	      c.background = contact[:background]
	      c.skype_name = contact[:skype_name]
	      c.birthday = contact[:birthday]
	      c.website = contact[:website]
	      c.is_company = contact[:is_company]
	      c.author_id = User.current.id
	      
        c.tag_list = params[:add_tag_list] 
	      unless params[:contact].blank?
	        c.assigned_to_id = params[:contact][:assigned_to_id] 
          # raise Error
          # c.custom_field_values = params[:contact][:custom_field_values]
        end
	      c.save
	    end  
	  end
	  redirect_to :controller => :contacts, :action => :index, :project_id => @project
	end

	def google_authorize
		token = exchange_singular_use_for_session_token(params[:token]) 

		if token
		  session[:token] = token
			redirect_to :action => :index, :project_id => @project
		else
			flash[:error] = "Something went wrong while authorizing with google."
			session[:token] = false
		end
	end
	
	private
	
	# Authorize the user for the requested right
  def authorize_for_import(global = false)
    allowed = User.current.allowed_to?(:import_contacts, @project || @projects, :global => global)
    if allowed
      true
    else
     deny_access
    end
  end
	
end
