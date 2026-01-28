Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"

  resources :trips, only: %i[index new create show edit update destroy] do
    member do
      get  :loading
      get  :status
      patch :update_preferences
      patch :save
      get  :export
    end
  end
end
