Trainwiki::Application.routes.draw do
  resources :journeys, :only => [:index, :show]
  resources :errors, :only => [:index, :show]
end
