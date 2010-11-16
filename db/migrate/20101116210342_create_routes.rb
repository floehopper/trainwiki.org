class CreateRoutes < ActiveRecord::Migration
  def self.up
    create_table :routes, :force => true do |t|
      t.integer :line_id
      t.integer :origin_station_id
      t.integer :destination_station_id
      t.timestamps
    end
    add_index :routes, :line_id
    add_index :routes, :origin_station_id
    add_index :routes, :destination_station_id
  end

  def self.down
    remove_index :routes, :destination_station_id
    remove_index :routes, :origin_station_id
    remove_index :routes, :line_id
    drop_table :routes
  end
end
