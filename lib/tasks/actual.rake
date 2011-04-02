namespace "actual" do
  desc "Scrape live departure boards for actual train arrival & departure times"
  task "scrape" => "environment" do
    unless File.new(__FILE__).flock(File::LOCK_EX | File::LOCK_NB)
      abort "Cannot obtain lock, another process is running this task"
    end
    begin
      puts "Running actual:scrape rake task..."

      destination_station = Station.find_by_name("London Kings Cross")
      boards = NationalRail::VirginLiveDepartureBoards.new
      boards.summary(destination_station.code).each do |row|
        if (row[:operator] == "East Coast Mainline") && (row[:to] == "**Terminates**") && row.details[:will_call_at].empty?
          puts
          next unless row.details[:previous_calling_points].any?

          origin_station = Station.first(:conditions => ['name LIKE ?', "#{row[:from]}%"])
          if origin_station.nil?
            puts "Origin station not found: #{row[:from]}"
            next
          end
          departs_at = row.details[:previous_calling_points][0][:timetabled_departure]
          arrives_at = row[:timetabled_arrival]
          departs_on = departs_at.to_date
          identifier = Journey.generate_identifier(origin_station, departs_at, destination_station, arrives_at, departs_on)
          journey = Journey.find_by_identifier(identifier)
          if journey.nil?
            puts "Creating journey for #{identifier}"
            journey = Journey.new
            journey.build_origin_departure(
              :journey => journey,
              :station => origin_station,
              :timetabled_at => departs_at
            )
            journey.build_destination_arrival(
              :journey => journey,
              :station => destination_station,
              :timetabled_at => arrives_at
            )
            journey.save!
          end
          puts identifier
          row.details[:previous_calling_points].each do |stop|
            station = Station.first(:conditions => ['name LIKE ?', "#{stop[:station]}%"])
            if station.nil?
              puts "Station not found: #{stop[:station]}"
              next
            end

            departure = journey.events.departures.at_station(station).first

            if departure.nil?
              puts "Creating departure event for #{station.code}"
              departure = journey.departures.build(
                :journey => journey,
                :station => station,
                :timetabled_at => stop[:timetabled_departure]
              )
              journey.save!
            end

            unless stop[:timetabled_departure] == departure.timetabled_at
              puts "Timetabled departure #{stop[:timetabled_departure].to_s(:time)} does not match #{departure.timetabled_at.to_s(:time)}"
            end

            happened_at = stop[:actual_departure]
            happened_at = stop[:timetabled_departure] if happened_at == "On time"
            if Time === happened_at
              puts "#{departure.station.code} - #{happened_at.to_s(:time)}"
              departure.update_attributes!(:happened_at => happened_at)
            else
              puts "#{departure.station.code} - #{happened_at}"
            end
          end

          arrival = journey.destination_arrival
          happened_at = row[:expected_arrival]
          happened_at = row[:timetabled_arrival] if happened_at == "On time"
          if Time === happened_at
            puts "#{arrival.station.code} - #{happened_at.to_s(:time)}"
            arrival.update_attributes!(:happened_at => happened_at)
          else
            puts "#{arrival.station.code} - #{happened_at}"
          end
        end
      end

      puts "...done."
    rescue => e
      HoptoadNotifier.notify(e)
      raise
    end
  end
end
