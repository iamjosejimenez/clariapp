Rails.application.routes.draw do
  get "sessions/new"
  get "sessions/create"
  get "sessions/destroy"
  get "goals/show"
  get "dashboard/show"
  root "sessions#new"

  post "/login", to: "sessions#create"
  delete "/logout", to: "sessions#destroy"

  get "/dashboard", to: "dashboard#show"

  resources :goals, only: [ :index, :show ] do
    member do
      get :snapshots
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
