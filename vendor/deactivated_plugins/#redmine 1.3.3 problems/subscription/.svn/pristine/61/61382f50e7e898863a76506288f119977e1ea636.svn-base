module NotifiableSubscriptionPatch

    def self.included(base)
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)
        base.class_eval do
            unloadable
            class << self
                alias_method_chain :all, :subscription
            end
        end
    end

    module ClassMethods

        def all_with_subscription
            notifications = all_without_subscription

            found = false
            news_index = 0
            notifications.each_with_index do |notification, index|
                news_index = index if notification.name == 'news_added'
                found = true if notification.name == 'news_comment_added'
            end
            notifications.insert(news_index + 1, Redmine::Notifiable.new('news_comment_added')) unless found

            notifications << Redmine::Notifiable.new('version_closed')
            notifications << Redmine::Notifiable.new('changeset_added')
            notifications << Redmine::Notifiable.new('board_added')

            notifications
        end

    end

    module InstanceMethods
    end

end
