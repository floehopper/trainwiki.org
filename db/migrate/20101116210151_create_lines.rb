class CreateLines < ActiveRecord::Migration
  def self.up
    create_table :lines, :force => true do |t|
      t.string :name
      t.timestamps
    end
    add_index :lines, :name
  end

  def self.down
    remove_index :lines, :name
    drop_table :lines
  end
end
