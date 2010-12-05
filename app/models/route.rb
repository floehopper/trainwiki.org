class Route < ActiveRecord::Base
  belongs_to :line
  belongs_to :origin_station, :class_name => "Station"
  belongs_to :destination_station, :class_name => "Station"
  has_many :errors

  def scrape_journeys(start_time)
    delay_average ||= ENV["DELAY_AVERAGE"].blank? ? 2 : Integer(ENV["DELAY_AVERAGE"])
    delay_variation ||= ENV["DELAY_VARIATION"].blank? ? 2 : Integer(ENV["DELAY_VARIATION"])
    origin = origin_station.name
    destination = destination_station.name
    time = start_time
    finished = false
    while !finished
      planner = NationalRail::JourneyPlanner.new
      puts "#{time.to_s(:short)} - search for journeys from #{origin} to #{destination}"

      begin
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
      rescue NationalRail::ParseError => e
        errors.create!(
          :search_from => time,
          :message => e.message,
          :backtrace => e.backtrace.join("\n"),
          :page_html => e.page_html
        )
        raise
      end

      if summary_rows.empty?
        time += 1.minute
      else
        time = summary_rows.last.departure_time + 1.minute
      end
    end
  end
end