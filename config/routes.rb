Rails.application.routes.draw do
  get "sessions/new"
  get "sessions/create"
  get "sessions/destroy"
  get "goals/show"
  get "dashboard/show"
  root "sessions#new"

  post "/login", to: "sessions#create", as: :login
  delete "/logout", to: "sessions#destroy", as: :logout

  resource :dashboard, only: [ :show ] do
    post :update_goals
  end

  resources :goals, only: [ :index, :show ] do
    member do
      get :snapshots
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
