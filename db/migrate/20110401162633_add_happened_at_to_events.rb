class AddHappenedAtToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :happened_at, :datetime
  end

  def self.down
    remove_column :events, :happened_at
  end
end
