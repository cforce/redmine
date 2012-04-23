module RedmineWikicreoleFormatter
  module Helper
    unloadable

    def wikitoolbar_for(field_id)
      file = 'http://dev.9thsoft.com/wiki/redmine-wikicreole/WikiFormatting'
      # Engines::RailsExtensions::AssetHelpers.plugin_asset_path('redmine_wikicreole_formatter', 'help', 'wikicreole_syntax.html')
      help_link = l(:setting_text_formatting) + ': ' +
      link_to(l(:label_help), file,
              :onclick => "window.open(\"#{file}\", \"\", \"resizable=yes, location=no, width=800, height=640, menubar=no, status=no, scrollbars=yes\"); return false;")

      javascript_include_tag('jstoolbar/jstoolbar') +
        javascript_include_tag('wikicreole', :plugin => 'redmine_wikicreole_formatter') +
        # javascript_include_tag("lang/wikicreole-#{current_language}", :plugin => 'redmine_wikicreole_formatter') +
        javascript_include_tag("jstoolbar/lang/jstoolbar-#{current_language}") +
        javascript_tag("var toolbar = new jsToolBar($('#{field_id}')); toolbar.setHelpLink('#{help_link}'); toolbar.draw();")
    end


    def initial_page_content(page)
      "= #{page.pretty_title} =\n"
    end

    def heads_for_wiki_formatter
      stylesheet_link_tag('jstoolbar')
    end
  end
end
