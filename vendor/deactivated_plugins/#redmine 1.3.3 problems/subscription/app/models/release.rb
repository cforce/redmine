class Release < ActiveRecord::Base
    belongs_to :version

    validates_presence_of :version
    validates_uniqueness_of :version_id
end
