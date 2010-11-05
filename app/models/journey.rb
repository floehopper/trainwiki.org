class Journey < ActiveRecord::Base

  has_many :events, :dependent => :destroy

  class << self
    def build_from(details)
      initial_stop = details[:initial_stop]
      journey = Journey.new
      journey.events << Event::OriginDeparture.new(
        :journey => journey,
        :station => Station.find_by_code(initial_stop[:station_code]),
        :timetabled_at => initial_stop[:departs_at]
      )
      details[:stops].each do |stop|
        journey.events << Event::Arrival.new(
          :journey => journey,
          :station => Station.find_by_code(stop[:station_code]),
          :timetabled_at => stop[:arrives_at]
        )
        journey.events << Event::Departure.new(
          :journey => journey,
          :station => Station.find_by_code(stop[:station_code]),
          :timetabled_at => stop[:departs_at]
        )
      end
      final_stop = details[:final_stop]
      journey.events << Event::DestinationArrival.new(
        :journey => journey,
        :station => Station.find_by_code(final_stop[:station_code]),
        :timetabled_at => final_stop[:arrives_at]
      )
      journey
    end
  end
end