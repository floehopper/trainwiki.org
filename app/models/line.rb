class Line < ActiveRecord::Base
  has_many :routes

  def scrape_journeys(start_time)
    routes.each do |route|
      route.scrape_journeys(start_time)
    end
  end
end