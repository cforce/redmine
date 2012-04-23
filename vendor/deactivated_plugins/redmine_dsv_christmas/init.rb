require 'redmine'

Redmine::Plugin.register :redmine_dsv_christmas do
  name 'Christmas for redmine'
  author 'Fabian Wallwitz'
  author_url ""
  description 'Let it snow..'
  url ""
  version '0.0.1'
  
  requires_redmine :version_or_higher => '1.1.2'
end

class DsvChristmasViewListener < Redmine::Hook::ViewListener

  # Adds javascript
  def view_layouts_base_html_head(context)
    javascript_include_tag('schnee.js', :plugin => :redmine_dsv_christmas)
  end

end
