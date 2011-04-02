class Journey < ActiveRecord::Base

  has_many :events, :dependent => :destroy
  has_one :origin_departure, :class_name => "Event::OriginDeparture"
  has_one :destination_arrival, :class_name => "Event::DestinationArrival"
  has_many :departures, :class_name => "Event::Departure"
  has_many :arrivals, :class_name => "Event::Arrival"
  has_many :stations, :through => :events, :uniq => true, :order => "events.timetabled_at"

  belongs_to :origin_station, :class_name => "Station"
  belongs_to :destination_station, :class_name => "Station"

  before_validation :set_origin
  before_validation :set_destination
  before_validation :set_identifier

  validates_presence_of :origin_departure
  validates_presence_of :destination_arrival
  validates_uniqueness_of :identifier
  validate :identifier_not_changed

  named_scope :departs_on, lambda { |date| { :conditions => ["DATE(departs_at) = ?", date] } }

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

    def parse_identifier(identifier)
      origin_code, departure_time, destination_code, arrival_time, departure_date = identifier.split("-")
      origin_station = Station.find_by_code(origin_code)
      departure_date.insert(4, "-").insert(-3, "-")
      departure_time.insert(2, ":")
      departs_at = Time.zone.parse("#{departure_time} #{departure_date}")
      destination_station = Station.find_by_code(destination_code)
      arrival_time.insert(2, ":")
      arrives_at = Time.zone.parse("#{arrival_time} #{departure_date}")
      [origin_station, departs_at, destination_station, arrives_at]
    end

    def find_canonical(identifier)
      origin_station, departs_at, destination_station, arrives_at = parse_identifier(identifier)
      departure_events = Event.departures.at_station(origin_station).timetabled_at(departs_at)
      arrival_events = Event.arrivals.at_station(destination_station).timetabled_at(arrives_at)
      journeys_in_common = departure_events.map(&:journey) & arrival_events.map(&:journey)
      case journeys_in_common.length
        when 0 then raise ActiveRecord::RecordNotFound, "No journey found for identifier: #{identifier}"
        when 1 then return journeys_in_common.first
        else raise "Multiple journeys found for identifier: #{identifier} which matches: #{journeys_in_common.map(&:identifier).inspect}"
      end
    end

    def generate_identifier(origin_station, departs_at, destination_station, arrives_at, departs_on)
      [
        origin_station.code,
        departs_at.to_s(:short_time),
        destination_station.code,
        arrives_at.to_s(:short_time),
        departs_on.to_s(:number)
      ].join("-")
    end
  end

  def generate_identifier
    self.class.generate_identifier(origin_station, departs_at, destination_station, arrives_at, departs_on)
  end

  def departs_on
    departs_at.to_date
  end

  def to_param
    identifier
  end

  def each_stop
    events.group_by(&:station).each do |station, events|
      arrival = events.detect { |e| Event::Arrival === e }
      departure = events.detect { |e| Event::Departure === e }
      yield(station, arrival, departure)
    end
  end

  private

  def set_origin
    self.origin_station = origin_departure.station
    self.departs_at = origin_departure.timetabled_at
  end

  def set_destination
    self.destination_station = destination_arrival.station
    self.arrives_at = destination_arrival.timetabled_at
  end

  def set_identifier
    self.identifier = generate_identifier
  end

  def identifier_not_changed
    if identifier_was.present? && identifier_changed?
      errors.add(:identifier, "cannot be changed from #{identifier_was} to #{identifier}")
    end
  end

  def must_have_exactly_one_origin_departure
    origin_departures = events.select { |e| Event::OriginDeparture === e }
    unless origin_departures.length == 1
      errors.add(:base, "must have exactly one origin departure (not #{origin_departures.length})")
    end
  end

  def must_have_exactly_one_destination_arrival
    destination_arrivals = events.select { |e| Event::DestinationArrival === e }
    unless destination_arrivals.length == 1
      errors.add(:base, "must have exactly one destination arrival (not #{destination_arrivals.length})")
    end
  end
end