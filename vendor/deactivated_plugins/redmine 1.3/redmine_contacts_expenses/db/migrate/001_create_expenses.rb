class CreateExpenses < ActiveRecord::Migration
  def self.up
    create_table :expenses do |t|
      t.date :expense_date
      t.decimal :price, :precision => 10, :scale => 2, :default => 0, :null => false
      t.text :description
      t.integer :contact_id
      t.integer :author_id
      t.integer :project_id
      t.integer :status_id
      t.timestamps
    end
    add_index :expenses, :contact_id 
    add_index :expenses, :project_id
    add_index :expenses, :status_id
    add_index :expenses, :author_id
  end

  def self.down
    drop_table :expenses
  end
end
