module RedmineContactsInvoices
  module Hooks
    class ViewsLayoutsHook < Redmine::Hook::ViewListener
      def view_layouts_base_html_head(context={})
        return content_tag(:style, "#admin-menu a.invoices { background-image: url('#{image_path('invoice.png', :plugin => 'redmine_contacts_invoices')}'); }", :type => 'text/css')
      end
    end
  end
end