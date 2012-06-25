require_dependency 'settings_controller'

# For Redmine 1.0.x
module SettingsSubscriptionPatch

    def self.included(base)
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)
        base.class_eval do
            unloadable
            alias_method_chain :edit, :subscription
        end
    end

    module ClassMethods
    end

    module InstanceMethods

        def edit_with_subscription
            edit_without_subscription

            unless @notifiables.include?('news_comment_added')
                news_index = @notifiables.index('news_added') || 0
                @notifiables.insert(news_index + 1, 'news_comment_added')
            end

            @notifiables << 'version_closed'
            @notifiables << 'changeset_added'
            @notifiables << 'board_added'
        end

    end

end
