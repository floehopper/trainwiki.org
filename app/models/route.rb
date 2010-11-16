class Route < ActiveRecord::Base
  belongs_to :line
  belongs_to :origin_station, :class_name => "Station"
  belongs_to :destination_station, :class_name => "Station"
end