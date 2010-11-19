class Line < ActiveRecord::Base
  has_many :routes

  def scrape_journeys(start_time, delay_average = 2, delay_variation = 2)
    routes.each do |route|
      route.scrape_journeys(start_time, delay_average, delay_variation)
    end
  end
end