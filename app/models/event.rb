class Event < ActiveRecord::Base

  belongs_to :journey
  belongs_to :station

  validates_presence_of :journey
  validates_presence_of :station
  validates_presence_of :timetabled_at

  default_scope :order => :timetabled_at

  scope :arrivals, :conditions => { :type => %w(Event::Arrival Event::DestinationArrival) }
  scope :departures, :conditions => { :type => %w(Event::Departure Event::OriginDeparture) }
  scope :origin_departures, :conditions => { :type => "Event::OriginDeparture" }
  scope :destination_arrivals, :conditions => { :type => "Event::DestinationArrival" }

  scope :at_station, lambda { |station| { :conditions => { :station_id => station.id } } }
  scope :timetabled_at, lambda { |time| { :conditions => ["timetabled_at = ?", time] } }

  def late_minutes
    return nil unless timetabled_at && happened_at
    ((happened_at - timetabled_at) / 60).to_i
  end
end