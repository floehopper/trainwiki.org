namespace "actual" do
  desc "Scrape live departure boards for actual train arrival & departure times"
  task "scrape" => "environment" do
    begin
      puts "Running actual:scrape rake task..."

      destination_station = Station.find_by_name("London Kings Cross")
      boards = NationalRail::VirginLiveDepartureBoards.new
      boards.summary(destination_station.code).each do |row|
        if (row[:operator] == "East Coast Mainline") && (row[:to] == "**Terminates**") && row.details[:will_call_at].empty?
          puts
          next unless row.details[:previous_calling_points].any?

          origin_station = Station.first(:conditions => ['name LIKE ?', "#{row[:from]}%"])
          departs_at = row.details[:previous_calling_points][0][:timetabled_departure]
          arrives_at = row[:timetabled_arrival]
          departs_on = departs_at.to_date
          identifier = Journey.generate_identifier(origin_station, departs_at, destination_station, arrives_at, departs_on)
          journey = Journey.find_by_identifier(identifier)
          if journey.nil?
            puts "No journey found for #{identifier}"
            next
          end
          puts identifier
          row.details[:previous_calling_points].each do |stop|
            station = Station.first(:conditions => ['name LIKE ?', "#{stop[:station]}%"])
            if station.nil?
              puts "Station not found: #{stop[:station]}"
              next
            end

            # i have seen a service amended to add an extra stop
            # in this case, there may be no existing departure
            # consider adding one...? or at least flagging this up
            departure = journey.events.departures.at_station(station).first

            timetabled_at = stop[:timetabled_departure]
            expected_at = stop[:expected_departure]
            happened_at = stop[:actual_departure]

            puts [station.code, departure ? departure.timetabled_at.strftime("%H:%M") : "no stop", timetabled_at.strftime("%H:%M"), Time === expected_at ? expected_at.strftime("%H:%M") : expected_at, Time === happened_at ? happened_at.strftime("%H:%M") : happened_at].join("\t")
          end
          station = journey.destination_station
          timetabled_at = journey.destination_arrival.timetabled_at
          expected_at = happened_at = row[:expected_arrival]
          # note that it looks like we need to infer the actual arrival from the last expected arrival time
          puts [station.code, journey.destination_arrival.timetabled_at.strftime("%H:%M"), timetabled_at.strftime("%H:%M"), Time === expected_at ? expected_at.strftime("%H:%M") : expected_at, Time === happened_at ? happened_at.strftime("%H:%M") : happened_at].join("\t")
        end
      end

      puts "...done."
    rescue => e
      HoptoadNotifier.notify(e)
      raise
    end
  end
end
