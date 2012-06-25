class CreateReleases < ActiveRecord::Migration

    def self.up
        create_table :releases do |t|
            t.column :version_id, :integer,  :null => false
            t.column :created_on, :datetime, :null => false
        end
        add_index :releases, [ :version_id ], :unique => true, :name => :releases_version_ids
    end

    def self.down
        drop_table :releases
    end

end
