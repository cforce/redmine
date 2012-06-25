require_dependency 'wiki_content'

module WikiContentSubscriptionPatch

    def self.included(base)
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)
        base.class_eval do
            unloadable
            alias_method_chain :recipients, :subscribers
        end
    end

    module ClassMethods
    end

    module InstanceMethods

        def recipients_with_subscribers
            notified = recipients_without_subscribers
            subscribers = ProjectSubscriber.find_all_by_project_id(project.id)
            notified += subscribers.select{ |subscriber| subscriber.subscribed_to?(:wiki_pages) && visible?(subscriber.user) }.collect{ |subscriber| subscriber.user.mail }
        end

    end

end
