class CreateErrors < ActiveRecord::Migration
  def self.up
    create_table :errors, :force => true do |t|
      t.integer :route_id
      t.string :message
      t.text :backtrace
      t.datetime :search_from
      t.text :page_html
      t.timestamps
    end
    add_index :errors, :route_id
  end

  def self.down
    remove_index :errors, :route_id
    drop_table :errors
  end
end