module DealsHelper
  def collection_for_status_select
    deal_statuses.collect{|s| [s.name, s.id.to_s]}
  end 
  
  def collection_for_currencies_select
    collection_for_currencies = [:en, :de, :'en-GB', :ru].each_with_index.collect{|l, index| [I18n.translate(:'number.currency.format.unit', :locale => l), index]}
    collection_for_currencies << ["¥", 4]
  end
  
  def deal_status_options_for_select(select="")    
     options_for_select(collection_for_status_select, select)
  end  
  
  def deals_sum_to_currency(deals_sum)
    deals_sum.map{|c| content_tag(:span, deal_price_to_currency(c[1], c[0].to_i), :style => "white-space: nowrap;")}.join(' / ')  
  end
  
  def deal_currency_icon(deal)
    case deal.currency
    when 0 
      "icon-money-dollar"
    when 1 
      "icon-money-euro"
    when 2 
      "icon-money-pound"
    when 3 
      "icon-money"
    when 4
      "icon-money-yen"
    else
      "icon-money"
    end
  end
  
  def deal_price_to_currency(price, currency)
    case currency
    when 0 
      loc = :en
    when 1 
      loc = :de
    when 2 
      loc = :'en-GB'
    when 3 
      loc = :ru
    when 4
      loc = nil
    else
    end  
       
    if !loc.blank? 
      number_to_currency(price, :locale => loc.to_sym, :precision => 2)
    else
      currency == 4 ? "¥" + number_with_delimiter(price, :delimiter => '', :precision => 2, :separator => '.' ) : number_with_delimiter(price, :delimiter => ' ', :precision => 2)
    end  
  end
  
  def deal_price(deal)
    deal_price_to_currency(deal.price, deal.currency)
  end
  
  def deal_statuses
    (!@project.blank? ? @project.deal_statuses : DealStatus.all(:order => "position")) || []
  end  
  
  def remove_contractor_link(contact) 
    link_to_remote(image_tag('delete.png'), 
			:url => {:controller => "deal_contacts", :action => 'delete', :project_id => @project, :deal_id => @deal, :contact_id => contact}, 
			:method => :delete, 
			:confirm => l(:text_are_you_sure),	
			:html => {:class  => "delete", :title => l(:button_delete) }) if  User.current.allowed_to?(:edit_deals, @project)
  end    
  
  def retrieve_date_range(period)   
    @from, @to = nil, nil
    case period 
    when 'today'
      @from = @to = Date.today
    when 'yesterday'
      @from = @to = Date.today - 1
    when 'current_week'
      @from = Date.today - (Date.today.cwday - 1)%7
      @to = @from + 6
    when 'last_week'
      @from = Date.today - 7 - (Date.today.cwday - 1)%7
      @to = @from + 6
    when '7_days'
      @from = Date.today - 7
      @to = Date.today
    when 'current_month'
      @from = Date.civil(Date.today.year, Date.today.month, 1)
      @to = (@from >> 1) - 1
    when 'last_month'
      @from = Date.civil(Date.today.year, Date.today.month, 1) << 1
      @to = (@from >> 1) - 1
    when '30_days'
      @from = Date.today - 30
      @to = Date.today
    when 'current_year'
      @from = Date.civil(Date.today.year, 1, 1)
      @to = Date.civil(Date.today.year, 12, 31)
    end    
    
    @from, @to = @from, @to + 1 if (@from && @to)
        
  end
  
  def deal_status_tag(deal_status)
    status_tag = content_tag(:span, deal_status.name) 
    content_tag(:span, status_tag, :class => "deal-status tags", :style => "background-color:#{deal_status.color_name};color:white;")
  end  
  
  
  def retrieve_deals_query
    # debugger
    # params.merge!(session[:deals_query])
    # session[:deals_query] = {:project_id => @project.id, :status_id => params[:status_id], :category_id => params[:category_id], :assigned_to_id => params[:assigned_to_id]}
    if params[:status_id] || !params[:period].blank? || !params[:category_id].blank? || !params[:assigned_to_id].blank? 
      session[:deals_query] = {:project_id => (@project ? @project.id : nil), 
                               :status_id => params[:status_id], 
                               :category_id => params[:category_id], 
                               :period => params[:period],
                               :assigned_to_id => params[:assigned_to_id]}
    else
      if api_request? || params[:set_filter] || session[:deals_query].nil? || session[:deals_query][:project_id] != (@project ? @project.id : nil)
        session[:deals_query] = {}
      else
        params.merge!(session[:deals_query])
      end
    end
  end
  
  
end
