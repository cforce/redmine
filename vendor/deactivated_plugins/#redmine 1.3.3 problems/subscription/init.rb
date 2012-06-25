require 'redmine'
require 'dispatcher'

require_dependency 'project_subscription_hook'

RAILS_DEFAULT_LOGGER.info 'Starting Project Subscription Plugin for Redmine'

unless ActiveRecord::Base.observers.include?(:comment_observer)
    ActiveRecord::Base.observers << :comment_observer
end

ActiveRecord::Base.observers << :version_observer
ActiveRecord::Base.observers << :changeset_observer
ActiveRecord::Base.observers << :board_observer

Dispatcher.to_prepare :subscription_plugin do
    unless News.included_modules.include?(NewsSubscriptionPatch)
        News.send(:include, NewsSubscriptionPatch)
    end
    unless WikiContent.included_modules.include?(WikiContentSubscriptionPatch)
        WikiContent.send(:include, WikiContentSubscriptionPatch)
    end
    unless Mailer.included_modules.include?(MailerSubscriptionPatch)
        Mailer.send(:include, MailerSubscriptionPatch)
    end
    if defined? Redmine::Notifiable
        unless Redmine::Notifiable.included_modules.include?(NotifiableSubscriptionPatch)
            Redmine::Notifiable.send(:include, NotifiableSubscriptionPatch)
        end
    else
        unless SettingsController.included_modules.include?(SettingsSubscriptionPatch)
            SettingsController.send(:include, SettingsSubscriptionPatch)
        end
    end
    unless Changeset.method_defined?(:identifier)
        unless Changeset.included_modules.include?(ChangesetSubscriptionPatch)
            Changeset.send(:include, ChangesetSubscriptionPatch)
        end
    end

    if Project.respond_to?(:add_available_column)
        Project.add_available_column(ExtendedColumn.new(:subscriptions,
                                                        :caption => :label_subscription_plural,
                                                        :value => lambda { |project| ProjectSubscriber.count(:conditions => [ "project_id = ?", project.id ]) },
                                                        :align => :center))
    end
    if User.respond_to?(:add_available_column)
        User.add_available_column(ExtendedColumn.new(:subscriptions,
                                                     :caption => :label_subscription_plural,
                                                     :value => lambda { |user| ProjectSubscriber.count(:conditions => [ "user_id = ?", user.id ]) },
                                                     :align => :center))
    end
end

Redmine::Plugin.register :subscription_plugin do
    name 'Project Subscription'
    author 'Andriy Lesyuk'
    author_url 'http://www.andriylesyuk.com/'
    description 'Adds ability to subscribe to project news, releases etc.'
    url 'http://projects.andriylesyuk.com/projects/subscription'
    version '0.0.1b'

    permission :subscribe_to_project, { :subscriptions => [ :subscription, :subscribe, :unsubscribe ] }
    permission :view_number_of_subscribers, {}
end
