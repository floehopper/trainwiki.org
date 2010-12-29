set :stages, %w(production)
set :default_stage, 'production'

require 'freerange/deploy'
require 'freerange/puppet'
require 'floehopper/deploy'

set :repository, 'git@github.com:floehopper/trainwiki.org.git'
set :application, 'trainwiki.org'
