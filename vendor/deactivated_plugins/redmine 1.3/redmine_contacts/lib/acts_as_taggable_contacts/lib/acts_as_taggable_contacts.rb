require "active_record"
require "action_view"

$LOAD_PATH.unshift(File.dirname(__FILE__))

require "acts_as_taggable_contacts/compatibility/active_record_backports" if ActiveRecord::VERSION::MAJOR < 3

require "acts_as_taggable_contacts/acts_as_taggable_contacts"
require "acts_as_taggable_contacts/acts_as_taggable_contacts/core"
require "acts_as_taggable_contacts/acts_as_taggable_contacts/collection"
require "acts_as_taggable_contacts/acts_as_taggable_contacts/cache"
require "acts_as_taggable_contacts/acts_as_taggable_contacts/ownership"
require "acts_as_taggable_contacts/acts_as_taggable_contacts/related"

require "acts_as_taggable_contacts/acts_as_tagger"
require "acts_as_taggable_contacts/tag"
require "acts_as_taggable_contacts/tag_list"
require "acts_as_taggable_contacts/tags_helper"
require "acts_as_taggable_contacts/tagging"

$LOAD_PATH.shift

if defined?(ActiveRecord::Base)
  ActiveRecord::Base.extend ActsAsTaggableContacts::Taggable
  ActiveRecord::Base.send :include, ActsAsTaggableContacts::Tagger
end

if defined?(ActionView::Base)
  ActionView::Base.send :include, ActsAsTaggableContacts::TagsHelper
end