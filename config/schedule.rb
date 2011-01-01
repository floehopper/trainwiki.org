set :output, 'log/whenever.log'

env :PATH, '/usr/bin:/bin:/usr/local/bin'

env :DELAY_AVERAGE, 5
env :DELAY_VARIATION, 3

every 5.minutes do
  rake 'timetable:scrape'
end
