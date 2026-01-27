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
      get "snapshot_detail/:snapshot_id", to: "goals#snapshot_detail", as: :snapshot_detail
    end
  end

  resources :budgets do
    resources :budget_periods, only: [ :index ] do
      resources :expenses, only: [ :new, :create, :index, :edit, :update, :destroy ]
    end
  end

  resources :expenses, only: [ :edit, :update, :destroy ]
  resources :invoices, only: [ :new, :create ]

  get "up" => "rails/health#show", as: :rails_health_check
end
