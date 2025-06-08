Rails.application.routes.draw do
  root "fintual_sessions#new"

  get "fintual_sessions/new"
  get "fintual_sessions/create"
  get "fintual_sessions/destroy"
  get "goals/show"
  get "dashboard/show"

  post "/login", to: "fintual_sessions#create", as: :login
  delete "/logout", to: "fintual_sessions#destroy", as: :logout

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
