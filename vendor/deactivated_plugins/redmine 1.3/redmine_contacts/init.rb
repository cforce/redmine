# Redmine contact plugin

require 'redmine'  
require 'redmine_contacts'

Redmine::Plugin.register :contacts do
  name 'CRM plugin'
  author 'RedmineCRM'
  description 'This is a CRM plugin for Redmine that can be used to track contacts and deals information'
  version '2.2.4-beta-1'
  url 'http://wwww.redminecrm.com'
  author_url 'mailto:kirbez@redminecrm.com'

  requires_redmine :version_or_higher => '1.2.2'   
  
  settings :default => {
    :use_gravatars => false, 
    :name_format => :lastname_firstname.to_s,
    :auto_thumbnails  => true,
    :max_thumbnail_file_size => 300
  }, :partial => 'settings/contacts'
  
  
  project_module :contacts_module do
    permission :view_contacts, { 
      :contacts => [:show, :index, :live_search, :contacts_notes, :context_menu],
      :contacts_tasks => :index, 
      :notes => [:show]
    }
    permission :edit_contacts, { 
      :contacts => [:edit, :update, :new, :create, :edit_tags],
      :notes => [:add_note, :destroy, :edit, :update],
      :contacts_tasks => [:new, :add, :delete, :close],
      :contacts_duplicates => [:index, :merge, :duplicates],
      :contacts_projects => [:add, :delete],
      :contacts_vcf => [:load]
    }
    permission :delete_contacts, :contacts => [:destroy, :bulk_destroy]
    permission :send_contacts_mail, :contacts => [:edit_mails, :send_mails, :preview_email]
    permission :add_notes, :notes => [:add_note]
    permission :delete_notes, :notes => [:destroy, :edit, :update]
    permission :delete_own_notes, :notes => [:destroy, :edit, :update]
    permission :delete_deals, :deals => [:destroy, :bulk_destroy]
    permission :view_deals, {
      :deals => [:index, :show, :context_menu], 
      :sale_funel => [:index], :public => true
    }
    permission :edit_deals, {
      :deals => [:new, :create, :edit, :update, :add_attachment, :bulk_update, :bulk_edit],   
      :deal_contacts => [:add, :delete],           
      :notes =>  [:add_note, :destroy_note]  
    }
    permission :manage_contacts, { 
      :projects => :settings, 
      :contacts_settings => :save, 
      :deal_categories => [:new, :edit, :destroy], 
      :deal_statuses => [:assing_to_project], :require => :member
    }
    permission :import_contacts, {}
  end

  menu :project_menu, :contacts, {:controller => 'contacts', :action => 'index'}, :caption => :contacts_title, :param => :project_id
  menu :project_menu, :deals, {:controller => 'deals', :action => 'index' }, 
                              :caption => :label_deal_plural, 
                              :if => Proc.new{|p| ContactsSetting[:contacts_show_deals_tab, p.id].to_i > 0 },
                              :param => :project_id

  menu :application_menu, :contacts, 
                          {:controller => 'contacts', :action => 'index'}, 
                          :caption => :label_contact_plural, 
                          :param => :project_id, 
                          :if => Proc.new{User.current.allowed_to?({:controller => 'contacts', :action => 'index'}, 
                                          nil, {:global => true})}
  menu :application_menu, :deals, 
                          {:controller => 'deals', :action => 'index'}, 
                          :caption => :label_deal_plural, 
                          :param => :project_id, 
                          :if => Proc.new{User.current.allowed_to?({:controller => 'deals', :action => 'index'}, 
                                          nil, {:global => true})}
  
  
  menu :top_menu, :contacts, {:controller => 'contacts', :action => 'index'}, :caption => :contacts_title, :if => Proc.new {
    User.current.allowed_to?({:controller => 'contacts', :action => 'index'}, nil, {:global => true})
  }  
  
  menu :admin_menu, :contacts, {:controller => 'settings', :action => 'plugin', :id => "contacts"}, :caption => :contacts_title, :param => :project_id
  
  activity_provider :contacts, :default => false, :class_name => ['DealNote', 'ContactNote']  
  # activity_provider :deals, :default => false, :class_name => ['DealNote']  

  Redmine::Search.map do |search|
    search.register :contacts
    search.register :deals
    search.register :contact_notes
    search.register :deal_notes
  end

  # activity_provider :contacts, :default => false   
end

