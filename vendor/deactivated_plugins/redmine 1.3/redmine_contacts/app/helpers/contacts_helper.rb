module ContactsHelper
  
  def authorized_for_permission?(permission, project, global = false)
    User.current.allowed_to?(permission, project, :global => global)
  end  
  
  def contacts_filters_for_select(selected)    
    selected ||= "" 
    options_for_select([[contacts_filter_name('0'), ActiveRecord::Base.connection.quoted_false.gsub(/'/, '')], 
                        [contacts_filter_name('1'), ActiveRecord::Base.connection.quoted_true.gsub(/'/, '')], 
                        [contacts_filter_name(''), ''], 
                        [contacts_filter_name('2'), '2'], 
                        [contacts_filter_name('3'), '3'], 
                        ['--------'], 
                        [l(:button_cancel), '-1']], :selected => selected, :disabled => "--------")
  end   
  
  def contacts_filter_name(value)
    case value
    when '0'
       l(:label_all_people)
    when '1'
       l(:label_all_companies)
    when '2'
        l(:label_recently_added_contacts)
    when '3'
        l(:label_created_by_me)
    else
       l(:label_all_people_and_companies)
    end 
  end

  def skype_to(skype_name, name = nil)
    return link_to skype_name, 'skype:' + skype_name + '?call' unless skype_name.blank?
  end
  
  def link_to_remote_list_update(text, url_params)
    link_to_remote(text,
      {:url => url_params, :method => :get, :update => 'contact_list', :complete => 'window.scrollTo(0,0)'},
      {:href => url_for(:params => url_params)}
    )
  end
  
  
  def contacts_paginator(paginator, page_options)     
    page_param = page_options.delete(:page_param) || :page
    per_page_links = page_options.delete(:per_page_links)
    url_param = params.dup
    # don't reuse query params if filters are present
    url_param.merge!(:fields => nil, :values => nil, :operators => nil) if url_param.delete(:set_filter)

    html = ''
    if paginator.current.previous
      html << link_to_remote_list_update('&#171; ' + l(:label_previous), url_param.merge(page_param => paginator.current.previous)) + ' '
    end

    html << (pagination_links_each(paginator, page_options) do |n|
      link_to_remote_list_update(n.to_s, url_param.merge(page_param => n))
    end || '')
    
    if paginator.current.next
      html << ' ' + link_to_remote_list_update((l(:label_next) + ' &#187;'), url_param.merge(page_param => paginator.current.next))
    end      
    
    html
    
  end
  
  def contact_url(contact)      
    return {:controller => 'contacts', :action => 'show', :project_id => @project, :id => contact.id }
  end  
  
  def deal_url(deal)
      return {:controller => 'deals', :action => 'show', :id => deal.id }
  end  

  def note_source_url(note_source)
    polymorphic_url(note_source)
    # return {:controller => note_source.class.name.pluralize.downcase, :action => 'show', :project_id => @project, :id => note_source.id }
  end
       
  def link_to_source(note_source, options={}) 
    return link_to note_source.name, note_source_url(note_source), options
  end

  def avatar_to(obj, options = { })  
    options[:size] = "64" unless options[:size]  
    size = options[:size]
    options[:size] = options[:size] + "x" + options[:size] 
    options[:class] = "gravatar" 
    
    avatar = obj.avatar unless Rails::env == "development"
    
    if avatar && FileTest.exists?(avatar.diskfile) && avatar.is_thumbnailable? then  # and obj.visible?  
      avatar_url = url_for :only_path => false, :controller => 'attachments', :action => 'download', :id => avatar, :filename => avatar.filename
      thumbnail_url = url_for(:only_path => false, 
                              :controller => 'attachments', 
                              :action => 'thumbnail', 
                              :id => avatar, 
                              :size => size)             
                          
      image_url = Object.const_defined?(:Magick) ? thumbnail_url : avatar_url
                          
      if options[:full_size] then
        image = link_to image_tag(image_url, options), avatar_url
      else 
        image = image_tag(image_url, options)
      end 
    end
    
   
    plugins_images = case obj  
      when Deal then "deal.png"
      when Contact then obj.is_company ? "company.png" : "person.png"
    end 
    plugins_images = image_path(plugins_images, :plugin => :redmine_contacts)
     
    if !image && Setting.plugin_contacts[:use_gravatar] && obj.class == Contact
      options[:default] = "#{request.protocol}#{request.host_with_port}" + plugins_images   
      options.merge!({:ssl => (defined?(request) && request.ssl?)})
      image = gravatar(obj.emails.first.downcase, options) rescue nil 
    end 
    
    image ||= image_tag(plugins_images, options)

  end
  
  def link_to_add_phone(name)             
    fields = '<p>' + label_tag(l(:field_contact_phone)) + 
      text_field_tag( "contact[phones][]", '', :size => 30 ) + 
      link_to_function(l(:label_remove), "removeField(this)") + '</p>'
    link_to_function(name, h("addField(this, '#{escape_javascript(fields)}' )"))
  end    
  
  def link_to_task_complete(url, bucket)
    onclick = "this.disable();"
    onclick << %Q/$("#{dom_id(pending, :name)}").style.textDecoration="line-through";/
    onclick << remote_function(:url => url, :method => :put, :with => "{ bucket: '#{bucket}' }")
  end   
  
  def render_contact_projects_hierarchy(projects)  
    s = ''
    project_tree(projects) do |project, level| 
      s << "<ul>"
      name_prefix = (level > 0 ? ('&nbsp;' * 2 * level + '&#187; ') : '')
        url = {:controller => 'contacts_projects',
               :action => 'delete',
               :disconnect_project_id => project.id,
               :project_id => @project.id,
               :contact_id => @contact.id}
      
      s << "<li>" + name_prefix + link_to_project(project)
      s += ' ' + link_to_remote(image_tag('delete.png'),
                                {:url => url},
                                :href => url_for(url),
                                :style => "vertical-align: middle",
                                :class => "delete") if (projects.size > 1 && authorize_for(:contacts, :edit) )       
      s << "</li>"                          

      s << "</ul>"
    end
    s
  end  
  
  def contact_to_vcard(contact)  
    return false if !Gem.available?('vpim') 

    require 'vpim/vcard'

    card = Vpim::Vcard::Maker.make2 do |maker|

      maker.add_name do |name|
        name.prefix = ''
        name.given = contact.first_name.to_s
        name.family = contact.last_name.to_s
        name.additional = contact.middle_name.to_s
      end

      maker.add_addr do |addr|
        addr.preferred = true
        addr.street = contact.address.to_s.gsub("\r\n"," ").gsub("\n"," ") 
      end
      
      maker.title = contact.job_title.to_s
      maker.org = contact.company.to_s   
      maker.birthday = contact.birthday.to_date unless contact.birthday.blank?
      maker.add_note(contact.background.to_s.gsub("\r\n"," ").gsub("\n", ' '))
       
      maker.add_url(contact.website.to_s)

      contact.phones.each { |phone| maker.add_tel(phone) }
      contact.emails.each { |email| maker.add_email(email) }
    end   
    avatar = contact.attachments.find_by_description('avatar')  
    card = card.encode.sub("END:VCARD", "PHOTO;BASE64:" + "\n " + [File.open(avatar.diskfile).read].pack('m').to_s.gsub(/[ \n]/, '').scan(/.{1,76}/).join("\n ") + "\nEND:VCARD") if avatar && avatar.readable?
    
    card.to_s 	
    
  end  
  
  def observe_fields(fields, options)
    #prepare a value of the :with parameter
    with = ""
    for field in fields
      with += "'"
      with += "&" if field != fields.first
      with += field + "='+escape($('#{field}').value)"
      with += " + " if field != fields.last
    end

    #generate a call of the observer_field helper for each field
    ret = "";
    for field in fields
      ret += observe_field(field,
      options.merge( { :with => with }))
    end
    ret
  end    

  def contacts_to_vcard(contacts)    
    contacts.map{|c| contact_to_vcard(c) }.join("\r\n")
  end
  
  def contacts_to_csv(contacts)
    ic = Iconv.new(l(:general_csv_encoding), 'UTF-8')
    decimal_separator = l(:general_csv_decimal_separator)
    export = FCSV.generate(:col_sep => l(:general_csv_separator)) do |csv|
      # csv header fields
      headers = [ "#",
                  l(:field_contact_first_name),
                  l(:field_contact_middle_name),
                  l(:field_contact_last_name),
                  l(:field_contact_job_title), 
                  l(:field_contact_company),   
                  l(:field_contact_phone),     
                  l(:field_contact_email),     
                  l(:field_contact_address),
                  l(:field_contact_skype),
                  l(:field_contact_website),   
                  l(:field_birthday),
                  l(:field_contact_tag_names),
                  l(:field_contact_background)
                  ]
      # Export project custom fields if project is given
      # otherwise export custom fields marked as "For all projects"
      custom_fields = ContactCustomField.for_all
      custom_fields.each {|f| headers << f.name}
      # Description in the last column
      csv << headers.collect {|c| begin; ic.iconv(c.to_s); rescue; c.to_s; end }
      # csv lines
      contacts.each do |contact|
        fields = [contact.id,
                  contact.first_name,
                  contact.middle_name,
                  contact.last_name,
                  contact.job_title,
                  contact.company,
                  contact.phone,
                  contact.email,
                  contact.address.to_s.gsub("\r\n"," ").gsub("\n", ' '),
                  contact.skype_name,
                  contact.website,
                  format_date(contact.birthday),
                  contact.tag_list,
                  contact.background.to_s.gsub("\r\n"," ").gsub("\n", ' ')
                  ]
        custom_fields.each {|f| fields << show_value(contact.custom_value_for(f)) }
        csv << fields.collect {|c| begin; ic.iconv(c.to_s); rescue; c.to_s; end }
      end
    end
    export
  end
  
  # Renders a HTML/CSS tooltip
  #
  # To use, a trigger div is needed.  This is a div with the class of "tooltip"
  # that contains this method wrapped in a span with the class of "tip"
  #
  #    <div class="tooltip"><%= link_to_issue(issue) %>
  #      <span class="tip"><%= render_issue_tooltip(issue) %></span>
  #    </div>
  #
  def render_contact_tooltip(contact, options={})
    @cached_label_company ||= l(:field_contact_company)
    @cached_label_job_title = contact.is_company ? l(:field_company_field) : l(:field_contact_job_title)
    @cached_label_phone ||= l(:field_contact_phone)
    @cached_label_email ||= l(:field_contact_email)
    
    emails = contact.emails.any? ? contact.emails.map{|email| "<span class=\"email\" style=\"white-space: nowrap;\">#{mail_to email}</span>"}.join(', ') : ''
    phones = contact.phones.any? ? contact.phones.map{|phone| "<span class=\"phone\" style=\"white-space: nowrap;\">#{phone}</span>"}.join(', ') : ''
    
    s = link_to_contact(contact, options) + "<br /><br />"
    s <<  "<strong>#{@cached_label_job_title}</strong>: #{contact.job_title}<br />" unless contact.job_title.blank?
    s <<  "<strong>#{@cached_label_company}</strong>: #{link_to(contact.contact_company.name, {:controller => 'contacts', :action => 'show', :id => contact.contact_company.id })}<br />" if !contact.contact_company.blank? && !contact.is_company
    s <<  "<strong>#{@cached_label_email}</strong>: #{emails}<br />" if contact.emails.any?
    s <<  "<strong>#{@cached_label_phone}</strong>: #{phones}<br />" if contact.phones.any?
    s
  end
  
  
  def link_to_contact(contact, options={})
    s = ''
    html_options = {}
    html_options = {:class => 'icon icon-vcard'} if options[:icon] == true
    s << avatar_to(contact, :size => "16") if options[:avatar] == true
 		s << link_to_source(contact, html_options)

 		s << "(#{contact.job_title}) " if (options[:job_title] == true) && !contact.job_title.blank?
		s << " #{l(:label_at_company)} " if (options[:job_title] == true) && !(contact.job_title.blank? or contact.company.blank?) 
		if (options[:company] == true) and contact.contact_company
			s << link_to(contact.contact_company.name, {:controller => 'contacts', :action => 'show', :id => contact.contact_company.id })
		else
			h contact.company
		end
 		s << "(#{l(:field_contact_tag_names)}: #{contact.tag_list.join(', ')}) " if (options[:tag_list] == true) && !contact.tag_list.blank?
    s
  end
  
  def retrieve_query
    # session[:]
    # if !params[:query_id].blank?
    #   cond = "project_id IS NULL"
    #   cond << " OR project_id = #{@project.id}" if @project
    #   @query = Query.find(params[:query_id], :conditions => cond)
    #   raise ::Unauthorized unless @query.visible?
    #   @query.project = @project
    #   session[:query] = {:id => @query.id, :project_id => @query.project_id}
    #   sort_clear
    # else
    #   if api_request? || params[:set_filter] || session[:query].nil? || session[:query][:project_id] != (@project ? @project.id : nil)
    #     # Give it a name, required to be valid
    #     @query = Query.new(:name => "_")
    #     @query.project = @project
    #     if params[:fields] || params[:f]
    #       @query.filters = {}
    #       @query.add_filters(params[:fields] || params[:f], params[:operators] || params[:op], params[:values] || params[:v])
    #     else
    #       @query.available_filters.keys.each do |field|
    #         @query.add_short_filter(field, params[field]) if params[field]
    #       end
    #     end
    #     @query.group_by = params[:group_by]
    #     @query.column_names = params[:c] || (params[:query] && params[:query][:column_names])
    #     session[:query] = {:project_id => @query.project_id, :filters => @query.filters, :group_by => @query.group_by, :column_names => @query.column_names}
    #   else
    #     @query = Query.find_by_id(session[:query][:id]) if session[:query][:id]
    #     @query ||= Query.new(:name => "_", :project => @project, :filters => session[:query][:filters], :group_by => session[:query][:group_by], :column_names => session[:query][:column_names])
    #     @query.project = @project
    #   end
    # end
  end
  
  
  
end
