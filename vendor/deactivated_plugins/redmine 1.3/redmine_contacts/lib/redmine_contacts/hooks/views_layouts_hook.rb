module RedmineContacts
  module Hooks
    class ViewsLayoutsHook < Redmine::Hook::ViewListener
      def view_layouts_base_html_head(context={})
        return content_tag(:style, "#admin-menu a.contacts { background-image: url('#{image_path('vcard.png', :plugin => 'redmine_contacts')}'); }", :type => 'text/css')
      end
    end
  end
end