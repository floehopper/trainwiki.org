namespace :db do

  desc "pull dump from production to development"
  task :production_to_development => :environment do
    development = ActiveRecord::Base.configurations["development"]
    production = ActiveRecord::Base.configurations["production"]
    export = "mysqldump -u#{production["username"]} #{production["database"]}"
    export += " -p#{production["password"]}" unless production["password"].blank?
    import = "mysql -u#{development["username"]} #{development["database"]}"
    import += " -p#{development["password"]}" unless development["password"].blank?
    system("ssh argonaut.slice #{export} | #{import}")
  end

end
