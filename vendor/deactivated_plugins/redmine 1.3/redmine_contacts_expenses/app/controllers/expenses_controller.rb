class ExpensesController < ApplicationController
  unloadable

  before_filter :find_expense_project, :only => [:create, :new]
  before_filter :find_expense, :only => [:edit, :show, :destroy, :update]  
  before_filter :bulk_find_expenses, :only => [:bulk_update, :bulk_edit, :bulk_destroy, :context_menu]
  before_filter :authorize, :except => [:index, :edit, :update, :destroy]
  before_filter :find_optional_project, :only => [:index] 

  accept_api_auth :index, :show, :create, :update, :destroy
  
  helper :contacts
  helper :invoices
  helper :custom_fields
  helper :timelog
  include ExpensesHelper
  include DealsHelper
  
  def index
    # retrieve_expenses_query
    @expenses_sum = find_expenses.sum(:price)
    respond_to do |format|
      format.html do
         @expenses = find_expenses
         render( :partial => 'list', :layout => false, :locals => {:expenses => @expenses}) if request.xhr?
      end   
      format.api { @expenses = find_expenses }
    end
  end

  def edit
  end

  def show
  end

  def new
    @expense = Expense.new
    @expense.expense_date = Date.today
  end

  def create
    @expense = Expense.new(params[:expense])  
    # @invoice.contacts = [Contact.find(params[:contacts])]
    @expense.project = @project 
    @expense.author = User.current  
    if @expense.save
      flash[:notice] = l(:notice_successful_create)
      
      respond_to do |format|
        format.html { redirect_to :action => "index", :project_id => @project }
        format.api  { render :action => 'show', :status => :created, :location => invoice_url(@expense) }
      end
    else
      respond_to do |format|
        format.html { render :action => 'new' }
        format.api  { render_validation_errors(@expense) }
      end
    end
    
  end
  
  def update
    (render_403; return false) unless @expense.editable_by?(User.current)
    if @expense.update_attributes(params[:expense]) 
      flash[:notice] = l(:notice_successful_update)  
      respond_to do |format| 
        format.html { redirect_to :action => "index", :project_id => @expense.project } 
        format.api  { head :ok }
      end  
    else           
      respond_to do |format|
        format.html { render :action => "edit"}
        format.api  { render_validation_errors(@expense) }
      end
    end
  end
  
  def destroy  
    (render_403; return false) unless @expense.destroyable_by?(User.current)
    if @expense.destroy
      flash[:notice] = l(:notice_successful_delete)
    else
      flash[:error] = l(:notice_unsuccessful_save)
    end
    respond_to do |format|
      format.html { redirect_to :action => "index", :project_id => @expense.project }
      format.api  { head :ok }
    end
    
  end
  
  def context_menu 
    @expense = @expenses.first if (@expenses.size == 1)
    @can = {:edit =>  @expenses.collect{|c| c.editable_by?(User.current)}.inject{|memo,d| memo && d}, 
            :delete => @expenses.collect{|c| c.destroyable_by?(User.current)}.inject{|memo,d| memo && d}
            }   
            
    # @back = back_url        
    render :layout => false  
  end   
  
  def bulk_destroy  
    @expenses.each do |expense|
      begin
        expense.reload.destroy
      rescue ::ActiveRecord::RecordNotFound # raised by #reload if issue no longer exists
        # nothing to do, issue was already deleted (eg. by a parent)
      end
    end
    respond_to do |format|
      format.html { redirect_back_or_default(:action => 'index', :project_id => @project) }
      format.api  { head :ok }
    end      
  end
  
  private
  
  def find_expenses(pages=true)  
    retrieve_date_range(params[:period].to_s)
    scope = Expense.scoped({})   
    scope = scope.by_project(@project.id) if @project
    scope = scope.scoped(:conditions => ["#{Expense.table_name}.status_id = ?", params[:status_id]]) if (!params[:status_id].blank? && params[:status_id] != "o" && params[:status_id] != "d")
    scope = scope.scoped(:conditions => ["#{Expense.table_name}.status_id <> ?", Expense::PAID_EXPENSE]) if (params[:status_id] == "o") || (params[:status_id] == "d")
    scope = scope.scoped(:conditions => ["#{Expense.table_name}.contact_id = ?", params[:contact_id]]) if !params[:contact_id].blank?
    scope = scope.scoped(:conditions => ["#{Expense.table_name}.assigned_to_id = ?", params[:assigned_to_id]]) if !params[:assigned_to_id].blank? 
    scope = scope.scoped(:conditions => ["#{Expense.table_name}.expense_date BETWEEN ? AND ?", @from, @to]) if (@from && @to)
                
    scope = scope.visible
    scope = scope.scoped(:order => "#{Expense.table_name}.expense_date") 
    
    @expenses_count = scope.count

    if pages 
      page_size = params[:page_size].blank? ? 20 : params[:page_size].to_i   
      @expenses_pages = Paginator.new(self, @expenses_count, page_size, params[:page])     
      @offset = @expenses_pages.current.offset  
      @limit =  @expenses_pages.items_per_page 
       
      scope = scope.scoped :limit  => @limit, :offset => @offset
      @expenses = scope
      
      fake_name = @expenses.first.price if @expenses.length > 0 #without this patch paging does not work
    end
    
    scope    
  end
  
  def bulk_find_expenses
    @expenses = Expense.find_all_by_id(params[:id] || params[:ids], :include => :project)
    raise ActiveRecord::RecordNotFound if @expenses.empty?
    if @expenses.detect {|expense| !expense.visible?}
      deny_access
      return
    end
    @projects = @expenses.collect(&:project).compact.uniq
    @project = @projects.first if @projects.size == 1
  rescue ActiveRecord::RecordNotFound
    render_404
  end
  
  def find_expense_project
    project_id = params[:project_id] || (params[:expense] && params[:expense][:project_id])
    @project = Project.find(project_id)
  rescue ActiveRecord::RecordNotFound
    render_404
  end
  
  def find_expense
    @expense = Expense.find(params[:id], :include => [:project, :contact])
    @project ||= @expense.project
  rescue ActiveRecord::RecordNotFound
    render_404
  end
  
end
