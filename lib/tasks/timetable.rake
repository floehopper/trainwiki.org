namespace "timetable" do
  desc "Scrape timetable for LINE from START_TIME until end of day with delay between requests specified by DELAY_AVERAGE & DELAY_VARIATION"
  task "scrape" => "environment" do
    puts "Running timetable:scrape rake task..."
    line_name = ENV["LINE"].blank? ? "East Coast" : ENV["LINE"]
    start_time = ENV["START_TIME"].blank? ? Date.tomorrow.beginning_of_day : Time.zone.parse(ENV["START_TIME"])
    puts "Time now is #{Time.zone.now}"
    puts "LINE=#{line_name}"
    puts "START_TIME=#{start_time}"
    line = Line.find_by_name!(line_name)
    line.scrape_journeys(start_time)
    puts "...done."
  end
end