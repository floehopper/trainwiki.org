require "national-rail"

class TimetableScraper

  def scrape(line_name, start_time, delay_average = 2, delay_variation = 2)
    line = Line.find_by_name!(line_name)
    line.routes.each do |route|
      origin = route.origin_station.name
      destination = route.destination_station.name
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
          unless company == line.name
            puts "#{timestamp} - skipped because journey is not an #{line.name} service"
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