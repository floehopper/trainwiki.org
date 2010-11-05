Trainwiki::Application.routes.draw do
  resources :journeys, :only => [:index, :show]
end
