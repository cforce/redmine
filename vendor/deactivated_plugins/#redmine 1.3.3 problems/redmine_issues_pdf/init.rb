require 'redmine'
require 'dispatcher'
require 'redmine_issues_pdf/hooks'
 
Dispatcher.to_prepare do
  RAILS_DEFAULT_LOGGER.debug "war hier 1"
  Redmine::Views::OtherFormatsBuilder.send(:include, OtherFormatsBuilderPatch)
  RAILS_DEFAULT_LOGGER.debug "war hier 2"
  Redmine::Export::PDF.send(:include, PDFExportPatch)
  RAILS_DEFAULT_LOGGER.debug "war hier 3"
end

Redmine::Plugin.register :redmine_issues_pdf do
  name 'Redmine Issues PDF Export'
  author 'cforce'
  description 'Allows exporting a set of Issues to one PDF file'
  version '0.0.2'
  
  requires_redmine :version_or_higher => '0.8.0'
  
end
