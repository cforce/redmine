class ContactJournal < ActiveRecord::Base
  unloadable
  belongs_to :contact
  belongs_to :journal

  acts_as_attachable :view_permission => :view_issues,  
                     :delete_permission => :edit_issues
                     
  def project
    journal.project
  end                   
                     
end
