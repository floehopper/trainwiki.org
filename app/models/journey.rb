class Journey < ActiveRecord::Base

  has_many :events, :dependent => :destroy
  has_one :origin_departure, :class_name => "Event::OriginDeparture"
  has_one :destination_arrival, :class_name => "Event::DestinationArrival"
  has_many :departures, :class_name => "Event::Departure"
  has_many :arrivals, :class_name => "Event::Arrival"
  has_many :stations, :through => :events, :uniq => true, :order => "events.timetabled_at"

  before_save :store_identifier

  class << self
    def build_from(details)
      initial_stop = details[:initial_stop]
      journey = Journey.new
      journey.build_origin_departure(
        :journey => journey,
        :station => Station.find_by_code(initial_stop[:station_code]),
        :timetabled_at => initial_stop[:departs_at]
      )
      details[:stops].each do |stop|
        station = Station.find_by_code(stop[:station_code])
        journey.arrivals.build(
          :journey => journey,
          :station => station,
          :timetabled_at => stop[:arrives_at]
        )
        journey.departures.build(
          :journey => journey,
          :station => station,
          :timetabled_at => stop[:departs_at]
        )
      end
      final_stop = details[:final_stop]
      journey.build_destination_arrival(
        :journey => journey,
        :station => Station.find_by_code(final_stop[:station_code]),
        :timetabled_at => final_stop[:arrives_at]
      )
      journey
    end
  end

  def departs_at
    origin_departure.timetabled_at
  end

  def origin_station
    origin_departure.station
  end

  def arrives_at
    destination_arrival.timetabled_at
  end

  def destination_station
    destination_arrival.station
  end

  def departs_on
    departs_at.to_date
  end

  def to_param
    identifier
  end

  def generate_identifier
    [
      origin_station.code,
      departs_at.to_s(:short_time),
      destination_station.code,
      arrives_at.to_s(:short_time),
      departs_on.to_s(:number)
    ].join("-")
  end

  def each_stop
    events.group_by(&:station).each do |station, events|
      arrival = events.detect { |e| Event::Arrival === e }
      departure = events.detect { |e| Event::Departure === e }
      yield(station, arrival, departure)
    end
  end

  private

  def store_identifier
    self.identifier = generate_identifier
  end
end