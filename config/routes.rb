# frozen_string_literal: true

Rails.application.routes.draw do
  get "budget_period/index"
  root "budgets#index"

  resource :session
  resources :passwords, param: :token

  get "fintual_sessions/new"
  post "fintual_sessions/create"

  get "gmail_sessions/new"
  post "gmail_sessions/authorize"
  get "gmail_sessions/callback"
  post "gmail_sessions/sync"
  delete "gmail_sessions", to: "gmail_sessions#destroy"

  resources :bank_emails, only: [ :index ] do
    member do
      get :detail
    end
  end
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

  resources :news, only: [ :index, :show ] do
    collection do
      post :refresh
    end
    member do
      get "summary_detail/:summary_id", to: "news#summary_detail", as: :summary_detail
    end
  end

  resources :budgets do
    resources :budget_periods, only: [ :index ] do
      resources :expenses, only: [ :new, :create, :index, :edit, :update, :destroy ]
    end
  end

  resources :expenses, only: [ :edit, :update, :destroy ]
  resources :invoices, only: [ :new, :create ]

  get "pruebas", to: "pruebas#index"
  get "pruebas/mensaje", to: "pruebas#mensaje", as: :pruebas_mensaje

  get "up" => "rails/health#show", as: :rails_health_check
end
