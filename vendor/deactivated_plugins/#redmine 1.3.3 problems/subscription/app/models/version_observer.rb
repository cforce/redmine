class VersionObserver < ActiveRecord::Observer

    def after_create(version)
        if version.closed?
            Release.create(:version => version)
            Mailer.deliver_version_closed(version) if Setting.notified_events.include?('version_closed')
        end
    end

    def after_update(version)
        if version.closed?
            unless Release.find_by_version_id(version.id)
                Release.create(:version => version)
                Mailer.deliver_version_closed(version) if Setting.notified_events.include?('version_closed')
            end
        end
    end

end
