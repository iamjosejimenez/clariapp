Rails.application.routes.draw do
  get "budget_period/index"
  root "budgets#index"

  resource :session
  resources :passwords, param: :token

  get "fintual_sessions/new"
  post "fintual_sessions/create"
  get "goals/show"
  get "dashboard/show"

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

  resources :budgets do
    resources :budget_periods, only: [ :index ] do
      resources :expenses, only: [ :new, :create, :index, :edit, :update ]
    end
  end

  resources :expenses, only: [ :edit, :update ]
  resources :invoices, only: [ :new, :create ]

  get "up" => "rails/health#show", as: :rails_health_check
end
