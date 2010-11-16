require "national-rail"
stations = NationalRail::StationList.new
stations.each do |name, code, latitude, longitude|
  Station.create!(:name => name, :code => code, :latitude => latitude, :longitude => longitude)
end

{
  "East Coast" => {
    %w(YRK) => %w(NCL),
    %w(NCL) => %w(GLC),
    %w(DON) => %w(GLC),
    %w(LDS) => %w(ABD),
    %w(KGX) => %w(LDS EDB GLC NCL ABD INV HUL BDQ SKI YRK),
    %w(PBO LDS NCL BDQ HUL SKI EDB HGT GLC ABD INV) => %w(KGX),
    %w(EDB) => %w(NCL),
    %w(ABD) => %w(EDB),
    %w(GLC) => %w(YRK)
  },

  "Southeast Trains - High Speed" => {
    %w(STP) => %w(RTR MAR FAV DVP EBD RAM AFK),
    %w(AFK FAV RAM DVP MAR EBD RTR) => %w(STP)
  }
}.each do |line, origins_vs_destinations|
  line = Line.create!(:name => line)
  origins_vs_destinations.each do |origins, destinations|
    origins.each do |origin|
      origin_station = Station.find_by_code!(origin)
      destinations.each do |destination|
        destination_station = Station.find_by_code!(destination)
        line.routes.create!(:origin_station => origin_station, :destination_station => destination_station)
      end
    end
  end
end
