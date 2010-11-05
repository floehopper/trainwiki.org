desc "This task is called by the Heroku cron add-on"
task :cron => :environment do
  puts "Running cron rake task..."
  Rake::Task["timetable:scrape"].invoke
  puts "...done."
end
