class CreateRecentlyVieweds < ActiveRecord::Migration
  def self.up
    create_table :recently_vieweds do |t|
      t.references :viewer
      t.references :viewed, :polymorphic => true
      t.column :views_count, :integer
      t.timestamps 
    end  
    
    add_index :recently_vieweds, [:viewed_id, :viewed_type], :name => "viewed_idx"   
    add_index :recently_vieweds, :viewer_id, :name => "viewer_idx"   
    
  end

  def self.down
    drop_table :recently_vieweds
  end
end
