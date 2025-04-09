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

  get "/dashboard", to: "dashboard#show"
  get "/goals/:id", to: "goals#show", as: :goal
  get "/goals/:id/movements", to: "goals#movements", as: :goal_movements
  get "up" => "rails/health#show", as: :rails_health_check
end
