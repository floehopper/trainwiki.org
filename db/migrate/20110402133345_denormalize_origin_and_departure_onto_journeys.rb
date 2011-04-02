class DenormalizeOriginAndDepartureOntoJourneys < ActiveRecord::Migration
  def self.up
    add_column :journeys, :origin_station_id, :integer
    add_column :journeys, :departs_at, :datetime
    add_column :journeys, :destination_station_id, :integer
    add_column :journeys, :arrives_at, :datetime

    add_index :journeys, :origin_station_id
    add_index :journeys, :departs_at
    add_index :journeys, :destination_station_id
    add_index :journeys, :arrives_at

    update %{
      UPDATE journeys, events
      SET journeys.origin_station_id = events.station_id, journeys.departs_at = events.timetabled_at
      WHERE journeys.id = events.journey_id AND events.type = 'Event::OriginDeparture'
    }

    update %{
      UPDATE journeys, events
      SET journeys.destination_station_id = events.station_id, journeys.arrives_at = events.timetabled_at
      WHERE journeys.id = events.journey_id AND events.type = 'Event::DestinationArrival'
    }
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
