class ChangesetObserver < ActiveRecord::Observer

    def after_create(changeset)
        Mailer.deliver_changeset_added(changeset) if Setting.notified_events.include?('changeset_added')
    end

end
