class Event
  class DestinationArrival < Arrival
    validates_uniqueness_of :journey_id
  end
end