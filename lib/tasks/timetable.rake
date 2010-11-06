namespace "timetable" do
  desc "Scrape timetable for LINE from START_TIME until end of day with delay between requests specified by DELAY_AVERAGE & DELAY_VARIATION"
  task "scrape" => "environment" do
    puts "Running timetable:scrape rake task..."
    scraper = TimetableScraper.new
    line = ENV["LINE"].blank? ? "East Coast Trains" : ENV["LINE"]
    start_time = ENV["START_TIME"].blank? ? Date.tomorrow.beginning_of_day : Time.zone.parse(ENV["START_TIME"])
    delay_average = ENV["DELAY_AVERAGE"].blank? ? 2 : Integer(ENV["DELAY_AVERAGE"])
    delay_variation = ENV["DELAY_VARIATION"].blank? ? 2 : Integer(ENV["DELAY_VARIATION"])
    puts "Time now is #{Time.zone.now}"
    puts "LINE=#{line}"
    puts "START_TIME=#{start_time}"
    puts "DELAY_AVERAGE=#{delay_average} seconds"
    puts "DELAY_VARIATION=#{delay_variation} seconds"
    scraper.scrape(line, start_time, delay_average, delay_variation)
    puts "...done."
  end
end