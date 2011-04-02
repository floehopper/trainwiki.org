class AddIndexToEventsType < ActiveRecord::Migration
  def self.up
    add_index :events, :type
  end

  def self.down
    remove_index :events, :type
  end
end
