module GoogleContactsHelper
  
  def build_auth_url(return_url)
		# The URL of the page that Google should redirect the user to after authentication.
		return_url = return_url
		# Indicates that the application is requesting a token to access contacts feeds. 
		scope_param = "http://www.google.com/m8/feeds/"
		# Indicates whether the client is requesting a secure token.
		secure_param = 0
		# Indicates whether the token returned can be exchanged for a multi-use (session) token.
		session_param = 1
		# root url
		root_url = "https://www.google.com/accounts/AuthSubRequest"

		root_url + "?scope=#{scope_param}&session=#{session_param}&secure=#{secure_param}&next=#{return_url}"
	end

	def exchange_singular_use_for_session_token(token)
		require 'net/http'
		require 'net/https'

		http = Net::HTTP.new('www.google.com', 443)
		http.use_ssl = true
		path = '/accounts/AuthSubSessionToken'
		headers = {'Authorization' => "AuthSub token=#{token}"}
		resp, data = http.get(path, headers)

		if resp.code == "200" 
			token = ''
			data.split.each do |str|
				if not (str =~ /Token=/).nil?
					token = str.gsub(/Token=/, '')
				end
			end
			return token
		else
			return false
		end
	end
	
  def get_google_contacts_data(token, params={})
		# GET http://www.google.com/m8/feeds/contacts/default/base
		require 'net/http'
		require 'rexml/document'      

		http = Net::HTTP.new('www.google.com', 80)
		# by default Google returns 50? contacts at a time.  Set max-results to very high number
		# in order to retrieve more contacts
    
    params[:"max-results"] ||= 10
    params[:"start-index"] ||= 1
    
		path = "/m8/feeds/contacts/default/full?#{params.to_query}"
		headers = {'Authorization' => "AuthSub token=#{token}", 'GData-Version' => '3.0'}
		resp, data = http.get(path, headers)
		data
  end
  
  def get_google_contacts(token, params={})
		# GET http://www.google.com/m8/feeds/contacts/default/base
		require 'net/http'
		require 'rexml/document' 
    # require 'open-uri'     

		http = Net::HTTP.new('www.google.com', 80)
		# by default Google returns 50? contacts at a time.  Set max-results to very high number
		# in order to retrieve more contacts
    
    params[:"max-results"] ||= 10
    params[:"start-index"] ||= 1
    
		path = "/m8/feeds/contacts/default/full?#{params.to_query}"
		headers = {'Authorization' => "AuthSub token=#{token}", 'GData-Version' => '3.0'}
		resp, data = http.get(path, headers)

		# extract the name and email address from the response data
		xml = REXML::Document.new(data)
		
		contacts = []
		
		xml.elements.each('//entry') do |entry|
		  contact = {}
      
      begin
  		  contact[:id] = entry.elements['id'].text
  		  contact[:title] = entry.elements['title'].text
  		  contact[:first_name] = entry.elements['gd:name/gd:givenName'].text if entry.elements['gd:name/gd:givenName']
  		  contact[:last_name] = entry.elements['gd:name/gd:familyName'].text if entry.elements['gd:name/gd:familyName']
  		  contact[:middle_name] = entry.elements['gd:name/gd:additionalName'].text if entry.elements['gd:name/gd:additionalName']
  		  contact[:phones] = entry.elements.collect('gd:phoneNumber', &:text).join(', ')
        contact[:emails] = entry.elements.collect('gd:email'){ |m| m.attributes['address']}.join(', ')
        contact[:address] = entry.elements['gd:structuredPostalAddress/gd:formattedAddress'].text if entry.elements['gd:structuredPostalAddress/gd:formattedAddress']
        contact[:company] = entry.elements['gd:organization/gd:orgName'].text if entry.elements['gd:organization/gd:orgName']
        contact[:job_title] = entry.elements['gd:organization/gd:orgTitle'].text if entry.elements['gd:organization/gd:orgTitle']
        contact[:background] = entry.elements["content"].text if entry.elements["content"]
        contact[:website] = entry.elements["gContact:website"].attributes["href"] if entry.elements["gContact:website"]
        contact[:skype_name] = entry.elements["gd:im"].attributes["address"] if (entry.elements["gd:im"] && entry.elements["gd:im"].attributes["protocol"] && entry.elements["gd:im"].attributes["protocol"].include?("SKYPE"))
        contact[:birthday] = Date.parse(entry.elements["gContact:birthday"].attributes["when"]) if entry.elements["gContact:birthday"]

        # contact[:avatar] = open('http://example.com/image.png').read 
      
        contact[:title] = '' if (contact[:first_name].blank? && contact[:last_name].blank? && contact[:middle_name].blank? && contact[:company].blank?)
        contact[:is_company] = (contact[:first_name].blank? && contact[:last_name].blank? && contact[:middle_name].blank?)
        contact[:title] = contact[:company] if contact[:title].blank?
        contact[:first_name] = contact[:title] if contact[:first_name].blank? 
        contact[:company] = '' if contact[:is_company]

  		  contacts << contact unless contact[:first_name].blank?
      rescue Exception => e
        flash[:error] << e.message
      end
	    
		end
		return contacts
	end
	
	
	
end
