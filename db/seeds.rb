require "national-rail"
stations = NationalRail::StationList.new
stations.each do |name, code, latitude, longitude|
  Station.create!(:name => name, :code => code, :latitude => latitude, :longitude => longitude)
end
