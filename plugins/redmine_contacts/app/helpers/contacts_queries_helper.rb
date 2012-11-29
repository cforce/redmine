module ContactsQueriesHelper
    def contacts_column_content(column, contact)
    value = column.value(contact)
    case value.class.name
    when 'String'
      if column.name == :subject
        link_to(h(value), :controller => 'contacts', :action => 'show', :id => contact)
      elsif  column.name == :name || column.name == :contacts
        contact_tag(contact)
      else
        h(value)
      end
    when 'Time'
      format_time(value)
    when 'Date'
      format_date(value)
    when 'Fixnum', 'Float'
      if column.name == :done_ratio
        progress_bar(value, :width => '80px')
      else
        h(value.to_s)
      end
    when 'User'
      link_to_user value
    when 'Project'
      link_to_project value
    when 'Version'
      link_to(h(value), :controller => 'versions', :action => 'show', :id => value)
    when 'TrueClass'
      l(:general_text_Yes)
    when 'FalseClass'
      l(:general_text_No)
    when 'Contact'
      link_to_contact(value, :subject => false)
    else
      h(value)
    end
  end

  # Retrieve query from session or build a new query
  def retrieve_contacts_query
    if !params[:query_id].blank?
      cond = "project_id IS NULL"
      cond << " OR project_id = #{@project.id}" if @project
      @query = ContactsQuery.find(params[:query_id], :conditions => cond)
      raise ::Unauthorized unless @query.visible?
      @query.project = @project
      session[:contacts_query] = {:id => @query.id, :project_id => @query.project_id}
      sort_clear
    elsif api_request? || params[:set_filter] || session[:contacts_query].nil? || session[:contacts_query][:project_id] != (@project ? @project.id : nil)
      # Give it a name, required to be valid
      @query = ContactsQuery.new(:name => "_")
      @query.project = @project
      build_contacts_query_from_params
      session[:contacts_query] = {:project_id => @query.project_id, :filters => @query.filters, :group_by => @query.group_by, :column_names => @query.column_names}
    else
      # retrieve from session
      @query = ContactsQuery.find_by_id(session[:contacts_query][:id]) if session[:contacts_query][:id]
      @query ||= ContactsQuery.new(:name => "_", :filters => session[:contacts_query][:filters], :group_by => session[:contacts_query][:group_by], :column_names => session[:contacts_query][:column_names])
      @query.project = @project
    end
  end

  def build_contacts_query_from_params
    if params[:fields] || params[:f]
      @query.filters = {}
      @query.add_filters(params[:fields] || params[:f], params[:operators] || params[:op], params[:values] || params[:v])
    else
      @query.available_filters.keys.each do |field|
        @query.add_short_filter(field, params[field]) if params[field]
      end
    end
    @query.group_by = params[:group_by] || (params[:query] && params[:query][:group_by])
    @query.column_names = params[:c] || (params[:query] && params[:query][:column_names])
  end
  def sidebar_contacts_queries
    unless @sidebar_queries
      @sidebar_queries = ContactsQuery.visible.all(
        :order => "#{ContactsQuery.table_name}.name ASC",
        # Project specific queries and global queries
        :conditions => (@project.nil? ? ["project_id IS NULL"] : ["project_id IS NULL OR project_id = ?", @project.id])
      )
    end
    @sidebar_queries
  end

  def contacts_query_links(title, queries)
    # links to #index on contacts/show
    url_params = controller_name == 'contacts' ? {:controller => 'contacts', :action => 'index', :project_id => @project} : params

    content_tag('h3', h(title)) +
      queries.collect {|query|
          link_to(h(query.name), url_params.merge(:query_id => query))
        }.join('<br />').html_safe
  end

  def render_sidebar_contacts_queries
    out = ''
    queries = sidebar_contacts_queries.select {|q| !q.is_public?}
    out << contacts_query_links(l(:label_my_queries), queries) if queries.any?
    queries = sidebar_contacts_queries.select {|q| q.is_public?}
    out << contacts_query_links(l(:label_query_plural), queries) if queries.any?
    out.html_safe
  end  

end
