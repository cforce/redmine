class ProjectSubscriber < ActiveRecord::Base
    belongs_to :project
    belongs_to :user

    serialize :subscribed_to, Array

    validates_presence_of :project, :user, :subscribed_to
    validates_uniqueness_of :user_id, :scope => :project_id

    def subscribed_to
        read_attribute(:subscribed_to) || []
    end

    def subscribed_to=(arg)
        items = []
        if arg.is_a?(String)
            arg = arg.split(',')
        end
        if arg.is_a?(Array)
            items = arg.uniq.select{ |a| a.to_s =~ %r{^[a-z_]+$} }.collect(&:to_sym)
        elsif arg.is_a?(Hash)
            items = arg.keys.select{ |a| arg[a].to_i == 1 && a.to_s =~ %r{^[a-z_]+$} }.collect(&:to_sym)
        end
        write_attribute(:subscribed_to, items)
    end

    def subscribed_to?(resource)
        subscribed_to.include?(resource.to_sym)
    end

end
