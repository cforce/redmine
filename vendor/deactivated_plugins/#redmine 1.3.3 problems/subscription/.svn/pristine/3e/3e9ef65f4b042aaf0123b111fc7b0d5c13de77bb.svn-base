require_dependency 'changeset'

module ChangesetSubscriptionPatch

    def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
            unloadable
        end
    end

    module InstanceMethods

        # Copy from Redmine 1.3.x
        def identifier
            if repository.class.respond_to?(:changeset_identifier)
                repository.class.changeset_identifier(self)
            else
                revision.to_s
            end
        end

        # Copy from Redmine 1.3.x
        def format_identifier
            if repository.class.respond_to?(:format_changeset_identifier)
                repository.class.format_changeset_identifier(self)
            else
                identifier
            end
        end

    end

end
