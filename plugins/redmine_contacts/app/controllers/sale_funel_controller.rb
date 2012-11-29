class SaleFunelController < ApplicationController
  unloadable
  
  before_filter :find_optional_project
  
  helper :timelog
  helper :contacts
  helper :deals 
  include DealsHelper  

  def index                                                                                               
    @sale_funel = []   
    deal_statuses.each do |status|
      retrieve_date_range(params[:period])
      scope = DealProcess.visible.scoped({}) 
      scope = scope.scoped(:conditions => ["#{Deal.table_name}.project_id = ?", @project.id]) if @project
      scope = scope.scoped(:conditions => ["#{Deal.table_name}.category_id = ?",  params[:category_id]]) if !params[:category_id].blank?
      scope = scope.scoped(:conditions => ["#{DealProcess.table_name}.value = ?", status.id])
      scope = scope.scoped(:conditions => ["#{DealStatus.table_name}.is_closed = ?", params[:is_closed]]) if !params[:is_closed].blank? 
      scope = scope.scoped(:conditions => ["#{DealProcess.table_name}.author_id = ?", params[:author_id]]) if !params[:author_id].blank? 
      scope = scope.scoped(:conditions => ["#{DealProcess.table_name}.created_at BETWEEN ? AND ?", @from, @to]) if (@from && @to)

      @sale_funel << [status, 
                      scope.count(:select => "DISTINCT deal_id", :include => {:deal => :status}),
                      scope.sum(:price, 
                                      :select => "DISTINCT #{Deal.table_name}.price", 
                                      :include => {:deal => :status}, 
                                      :group => "#{Deal.table_name}.currency")
                      ] 
    end
    
    respond_to do |format|
      format.html{ render( :partial => "sale_funel", :layout => false) if request.xhr? }
      format.xml { render :xml => @sale_funel}  
      format.json { render :text => @sale_funel.to_json, :layout => false } 
    end
    
    
  end
end
