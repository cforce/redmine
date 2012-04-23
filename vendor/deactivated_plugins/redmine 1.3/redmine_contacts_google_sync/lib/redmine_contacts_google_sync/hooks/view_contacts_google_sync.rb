module Redmine
  module ContactsGoogleSync
    module Hooks
      class ShowImportLinkHook < Redmine::Hook::ViewListener     
        render_on :view_contacts_project_settings_top, :partial => "hooks/contacts_google_import" 
      end   
    end
  end
end