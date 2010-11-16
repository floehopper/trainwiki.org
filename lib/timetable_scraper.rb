require "national-rail"

class TimetableScraper

  ORIGINS_VS_DESTINATIONS = {

    "East Coast" => {
      ["York"] => ["Newcastle"],
      ["Newcastle"] => ["Glasgow Central"],
      ["Doncaster"] => ["Glasgow Central"],
      ["Leeds"] => ["Aberdeen"],
      ["London Kings Cross"] => ["Leeds", "Edinburgh", "Glasgow Central", "Newcastle", "Aberdeen", "Inverness", "Hull", "Bradford Forster Square", "Skipton", "York"],
      ["Peterborough", "Leeds", "Newcastle", "Bradford Forster Square", "Hull", "Skipton", "Edinburgh", "Harrogate", "Glasgow Central", "Aberdeen", "Inverness"] => ["London Kings Cross"],
      ["Edinburgh"] => ["Newcastle"],
      ["Aberdeen"] => ["Edinburgh"],
      ["Glasgow Central"] => ["York"]
    },

    "Southeast Trains - High Speed" => {
      ["London St Pancras (Domestic)"] => ["Rochester", "Margate", "Faversham", "Dover Priory", "Ebbsfleet International", "Ramsgate", "Ashford International"],
      ["Ashford International", "Faversham", "Ramsgate", "Dover Priory", "Margate", "Ebbsfleet International", "Rochester"] => ["London St Pancras (Domestic)"]
    }
  }

  def scrape(line, start_time, delay_average = 2, delay_variation = 2)
    ORIGINS_VS_DESTINATIONS[line].each do |origins, destinations|
      origins.each do |origin|
        destinations.each do |destination|
          time = start_time
          finished = false
          while !finished
            planner = NationalRail::JourneyPlanner.new
            puts "#{time.to_s(:short)} - search for journeys from #{origin} to #{destination}"

            summary_rows = planner.plan(:from => origin, :to => destination, :time => time)
            summary_rows.each do |summary_row|
              timestamp = summary_row.departure_time.to_s(:short)

              unless summary_row.departure_time > time
                puts "#{timestamp} - skipped because departure time is earlier than the search time"
                next
              end
              unless summary_row.departure_time.to_date == time.to_date
                puts "#{timestamp} - aborting because departure time is not on the same day"
                finished = true
                break
              end
              unless summary_row.number_of_changes == "0"
                puts "#{timestamp} - skipped because it has #{summary_row.number_of_changes} changes"
                next
              end

              details = summary_row.details

              company = details[:company]
              unless company == line
                puts "#{timestamp} - skipped because journey is not an #{line} service"
                next
              end

              origins, destinations = details[:origins], details[:destinations]
              unless origins.include?(origin) && destinations.include?(destination)
                puts "#{timestamp} - skipped because journey is from #{origins.join(",")} to #{destinations.join(",")} (not from #{origin} to #{destination})"
                next
              end
              puts "#{timestamp} --->>> departure with #{details[:stops].length} stops found"

              journey = Journey.build_from(details)

              unless journey.save
                puts "#{timestamp} - journey not valid: #{journey.errors.full_messages.join(", ")}"
              end

              GC.start
              sleep(delay_average + (delay_variation * 2) * (rand - 0.5))
            end

            if summary_rows.empty?
              time += 1.minute
            else
              time = summary_rows.last.departure_time + 1.minute
            end
          end
        end
      end
    end
  end
end