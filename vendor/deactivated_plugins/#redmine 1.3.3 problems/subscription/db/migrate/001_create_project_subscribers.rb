class CreateProjectSubscribers < ActiveRecord::Migration

    def self.up
        create_table :project_subscribers do |t|
            t.column :project_id,    :integer, :null => false
            t.column :user_id,       :integer, :null => false
            t.column :subscribed_to, :text
        end
        add_index :project_subscribers, [ :project_id, :user_id ], :unique => true, :name => :project_subscribers_ids
    end

    def self.down
        drop_table :project_subscribers
    end

end
