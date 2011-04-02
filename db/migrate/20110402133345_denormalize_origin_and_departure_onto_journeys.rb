class DenormalizeOriginAndDepartureOntoJourneys < ActiveRecord::Migration
  def self.up
    # add_column :journeys, :origin_station_id, :integer
    # add_column :journeys, :departs_at, :datetime
    # add_column :journeys, :destination_station_id, :integer
    # add_column :journeys, :arrives_at, :datetime
    # 
    # add_index :journeys, :origin_station_id
    # add_index :journeys, :departs_at
    # add_index :journeys, :destination_station_id
    # add_index :journeys, :arrives_at

    Journey.all.each { |j| j.save }
  end

  def self.down
    remove_index :journeys, :arrives_at
    remove_index :journeys, :destination_station_id
    remove_index :journeys, :departs_at
    remove_index :journeys, :origin_station_id

    remove_column :journeys, :arrives_at
    remove_column :journeys, :destination_station_id
    remove_column :journeys, :departs_at
    remove_column :journeys, :origin_station_id
  end
end
