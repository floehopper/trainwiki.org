namespace "timetable" do
  desc "Scrape timetable for LINE from START_TIME until end of day with delay between requests specified by DELAY_AVERAGE & DELAY_VARIATION"
  task "scrape" => "environment" do
    scraper = TimetableScraper.new
    line = ENV["LINE"].blank? ? "East Coast Trains" : ENV["LINE"]
    date = ENV["START_TIME"].blank? ? Date.tomorrow.to_time.in_time_zone : Time.zone.parse(ENV["START_TIME"])
    delay_average = ENV["DELAY_AVERAGE"].blank? ? 2 : Integer(ENV["DELAY_AVERAGE"])
    delay_variation = ENV["DELAY_VARIATION"].blank? ? 2 : Integer(ENV["DELAY_VARIATION"])
    scraper.scrape(line, date, delay_average, delay_variation)
  end
end