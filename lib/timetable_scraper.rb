require "national-rail"

class TimetableScraper

  def scrape(line_name, start_time, delay_average = 2, delay_variation = 2)
    line = Line.find_by_name!(line_name)
    line.routes.each do |route|
      route.scrape_journeys(start_time, delay_average, delay_variation)
    end
  end
end