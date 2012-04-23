# Redmine WikiCreole formatter
require 'redmine'

RAILS_DEFAULT_LOGGER.info 'Starting WikiCreole formatter for Redmine'

Redmine::Plugin.register :redmine_wikicreole_formatter do
    name 'WikiCreole Formatter'
    author 'Brant Young <brant@9thsoft.com>'
    description 'This provides WikiCreole as a wiki format'
    version '0.1'
    
    wiki_format_provider 'wikicreole', RedmineWikicreoleFormatter::WikiFormatter, \
                            RedmineWikicreoleFormatter::Helper
end
