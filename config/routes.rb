Rails.application.routes.draw do
  get 'trips/index'
  get 'trips/new'
  get 'trips/create'
  get 'trips/show'
  get 'trips/loading'
  root "pages#home"

  devise_for :users

  resources :trips do
    member do
      post :generate        # create itinerary_days + activities + transport options
      post :confirm        # user confirms final plan
      get  :export          # PDF export
    end

    # Preferences adjustment
    resource :trip_preferences, only: [:create, :update] # itinerary_days → activities #transport_options



    # Read-only after generation
    resources :itinerary_days, only: [:index, :show] do
      resources :activities, only: [:create, :update, :destroy]
    end


    # Transport options comparison
    resources :transport_options, only: [:index, :show]
  end

	  resources :activities, only: [:destroy]
end
