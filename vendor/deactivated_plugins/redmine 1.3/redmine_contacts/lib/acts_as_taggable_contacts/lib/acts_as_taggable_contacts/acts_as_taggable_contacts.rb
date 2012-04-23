module ActsAsTaggableContacts
  module Taggable
    def taggable?
      false
    end

    ##
    # This is an alias for calling <tt>acts_as_taggable_contacts :tags</tt>.
    #
    # Example:
    #   class Book < ActiveRecord::Base
    #     acts_as_taggable
    #   end
    def acts_as_taggable
      acts_as_taggable_contacts :tags
    end

    ##
    # Make a model taggable on specified contexts.
    #
    # @param [Array] tag_types An array of taggable contexts
    #
    # Example:
    #   class User < ActiveRecord::Base
    #     acts_as_taggable_contacts :languages, :skills
    #   end
    def acts_as_taggable_contacts(*tag_types)
      tag_types = tag_types.to_a.flatten.compact.map(&:to_sym)

      if taggable?
        write_inheritable_attribute(:tag_types, (self.tag_types + tag_types).uniq)
      else
        write_inheritable_attribute(:tag_types, tag_types)
        class_inheritable_reader(:tag_types)
        
        class_eval do
          has_many :taggings, :as => :taggable, :dependent => :destroy, :include => :tag, :class_name => "ActsAsTaggableContacts::Tagging"
          has_many :base_tags, :through => :taggings, :source => :tag, :class_name => "ActsAsTaggableContacts::Tag"

          def self.taggable?
            true
          end
        
          include ActsAsTaggableContacts::Taggable::Core
          include ActsAsTaggableContacts::Taggable::Collection
          include ActsAsTaggableContacts::Taggable::Cache
          include ActsAsTaggableContacts::Taggable::Ownership
          include ActsAsTaggableContacts::Taggable::Related
        end
      end
    end
  end
end
