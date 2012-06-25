class ProjectSubscriptionHook  < Redmine::Hook::ViewListener

    render_on :view_layouts_base_html_head, :partial => 'subscribe/sidebar'

end
