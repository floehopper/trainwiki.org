set :output, 'log/whenever.log'

env :DELAY_AVERAGE, 5
env :DELAY_VARIATION, 3

every 1.day, :at => '5:00pm' do
  rake 'timetable:scrape'
end