class TaggableModel < ActiveRecord::Base
  acts_as_taggable
  acts_as_taggable_contacts :languages
  acts_as_taggable_contacts :skills
  acts_as_taggable_contacts :needs, :offerings
  has_many :untaggable_models
end

class CachedModel < ActiveRecord::Base
  acts_as_taggable
end

class OtherTaggableModel < ActiveRecord::Base
  acts_as_taggable_contacts :tags, :languages
  acts_as_taggable_contacts :needs, :offerings
end

class InheritingTaggableModel < TaggableModel
end

class AlteredInheritingTaggableModel < TaggableModel
  acts_as_taggable_contacts :parts
end

class TaggableUser < ActiveRecord::Base
  acts_as_tagger
end

class UntaggableModel < ActiveRecord::Base
  belongs_to :taggable_model
end