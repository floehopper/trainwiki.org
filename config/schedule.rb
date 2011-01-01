set :output, 'log/whenever.log'

env :PATH, '/usr/bin:/bin:/usr/local/bin'

env :DELAY_AVERAGE, 5
env :DELAY_VARIATION, 3

every 1.day, :at => '2:00am' do
  rake 'timetable:scrape'
end

every 1.minute do
  command 'env', :output => 'temp.log'
end