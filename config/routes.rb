Rails.application.routes.draw do
  root "budgets#index"

  resource :session
  resources :passwords, param: :token

  get "fintual_sessions/new"
  get "fintual_sessions/create"
  get "fintual_sessions/destroy"
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
    resources :budget_periods, only: [] do
      resources :expenses, only: [ :new, :create, :index ]
    end
  end


  get "up" => "rails/health#show", as: :rails_health_check
end
