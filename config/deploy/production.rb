server 'argonaut.slice', :app, :web, :db, :primary => true

manifest :app, %{
  floehopper::rails_app {'trainwiki.org':
    deploy_to => "<%= deploy_to %>",
    domain => 'trainwiki.org'
  }
}

manifest :db, %{
  floehopper::rails_db {'trainwiki':
    environment => 'production',
    password => 'jump50,biked'
  }
}
