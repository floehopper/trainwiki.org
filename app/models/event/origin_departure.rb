class Event
  class OriginDeparture < Departure
    validates_uniqueness_of :journey_id
  end
end