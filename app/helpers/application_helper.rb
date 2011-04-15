module ApplicationHelper
  def journey_description(journey)
    "#{journey.departs_at.to_s(:time)} #{journey.origin_station.name} to #{journey.destination_station.name} on #{journey.departs_on.to_s(:full_ordinal)}"
  end
end
