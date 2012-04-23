require File.expand_path(File.dirname(__FILE__) + '/../../../../test/test_helper')
# require 'redgreen'  

Engines::Testing.set_fixture_path    

class RedmineContacts::TestCase  
  
  def uploaded_test_file(name, mime)
    ActionController::TestUploadedFile.new(ActiveSupport::TestCase.fixture_path + "/files/#{name}", mime, true)
  end
  
  def self.is_arrays_equal(a1, a2)
    (a1 - a2) - (a2 - a1) == []
  end  
       
  def self.prepare
    Role.find(1, 2, 3, 4).each do |r| 
      r.permissions << :view_contacts
      r.save
    end
    Role.find(1, 2).each do |r| 
      r.permissions << :edit_contacts
      r.save
    end
    Role.find(1, 2, 3).each do |r| 
      r.permissions << :view_deals
      r.save
    end 
    
    Role.find(2) do |r| 
      r.permissions << :edit_deals
      r.save
    end 

    Project.find(1, 2, 3, 4, 5).each do |project| 
      EnabledModule.create(:project => project, :name => 'contacts_module')
    end
  end   
  
end