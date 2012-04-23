require 'redmine'
require 'redmine_contacts_invoices'

config.gem "prawn", :version => '0.12.0'

Redmine::Plugin.register :redmine_contacts_invoices do
  name 'Redmine Contacts Invoices plugin'
  author 'RedmineCRM'
  description 'PLugin for track invoices'
  version '1.0.3'
  url 'http://redminecrm.com/projects/invocies'
  author_url 'mailto:kirbez@redminecrm.com'
  
  requires_redmine :version_or_higher => '1.2.2'   
  requires_redmine_plugin :contacts, :version_or_higher => '2.2.1'
  
  settings :default => {
    :company_name => "Your company name",
    :company_representative => "Company representative name",
    :template  => "classic",
    :currecy_format  => "classic",
    :line_grouping => 0,
    :total_including_tax => false,
    :excerpt_invoice_list => true,
    :default_currency => "USD",
    :decimal_separator => ".",
    :thousands_delimiter => " ",
    :number_format => '#INV/%%YEAR%%%%MONTH%%%%DAY%%-%%ID%%',
    :company_info => "Your company address\nTax ID\nphone:\nfax:",
    :company_logo_url => "http://www.redmine.org/attachments/3458/redmine_logo_v1.png",
    :bill_info => "Your billing information (Bank, Address, IBAN, SWIFT & etc.)",
    :units  => "hours\ndays\nservice\nproducts"
  }, :partial => 'settings/contacts_invoices'
  
  
  project_module :contacts_invoices do
     permission :view_invoices, :invoices => [:index, :show, :context_menu]
     permission :edit_invoices, :invoices => [:new, :create, :edit, :update],
                                :invoice_time_entries => [:new]
     permission :edit_own_invoices, :invoices => [:new, :create, :edit, :update, :delete]
     permission :delete_invoices, :invoices => [:destroy, :bulk_destroy]
     # permission :send_invoices, :invoice_mails => [:send]
  end   
  
  menu :application_menu, :invoices, 
                          {:controller => 'invoices', :action => 'index'}, 
                          :caption => :label_invoice_plural, 
                          :param => :project_id, 
                          :if => Proc.new{User.current.allowed_to?({:controller => 'invoices', :action => 'index'}, 
                                          nil, {:global => true})}
  
  
  menu :project_menu, :invoices, {:controller => 'invoices', :action => 'index'}, :caption => :label_invoice_plural, :param => :project_id
  
  menu :admin_menu, :invoices, {:controller => 'settings', :action => 'plugin', :id => "redmine_contacts_invoices"}, :caption => :label_invoice_plural, :param => :project_id
  
  activity_provider :invoices, :default => false, :class_name => ['Invoice'] 
  
  Redmine::Search.map do |search|
    search.register :invoices
  end
  
end
