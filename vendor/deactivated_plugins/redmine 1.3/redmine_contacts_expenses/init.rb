require 'redmine'
require 'redmine_contacts_expenses'

Redmine::Plugin.register :redmine_contacts_expenses do
  name 'Redmine Contacts Expenses plugin'
  author 'RedmineCRM'
  description 'Plugin for track expenses'
  version '1.0.3'
  url 'http://redminecrm.com/projects/expenses'
  author_url 'mailto:kirbez@redminecrm.com'
  
  requires_redmine :version_or_higher => '1.2.2'   
  requires_redmine_plugin :contacts, :version_or_higher => '2.2.1'
  
  project_module :contacts_expenses do
     permission :view_expenses, :expenses => [:index, :show, :context_menu]
     permission :edit_expenses, :expenses => [:new, :create, :edit, :update]
     permission :edit_own_expenses, :expenses => [:new, :create, :edit, :update, :delete]
     permission :delete_expenses, :expenses => [:destroy, :bulk_destroy]
  end   
  
  menu :application_menu, :expenses, 
                          {:controller => 'expenses', :action => 'index'}, 
                          :caption => :label_expense_plural, 
                          :param => :project_id, 
                          :if => Proc.new{User.current.allowed_to?({:controller => 'expenses', :action => 'index'}, 
                                          nil, {:global => true})}
  
  
  menu :project_menu, :expenses, {:controller => 'expenses', :action => 'index'}, :caption => :label_expense_plural, :param => :project_id
  
  activity_provider :expenses, :default => false, :class_name => ['Expense'] 
  
  Redmine::Search.map do |search|
    search.register :expenses
  end
  
end
