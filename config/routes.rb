Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: "registrations"
  }

  # Root redirects to role-specific dashboard after login
  authenticated :user do
    root to: "dashboards#show", as: :authenticated_root
  end
  root to: redirect("/users/sign_in")

  # Admin namespace
  namespace :admin do
    get "dashboard", to: "dashboards#show", as: :dashboard
    resources :service_requests, only: [:index, :show] do
      member do
        patch :assign
      end
    end
    resources :users, only: [:index, :new, :create, :edit, :update]
    resources :customers, only: [:index, :show]
    get "analytics", to: "analytics#index", as: :analytics
  end

  # Technician namespace
  namespace :technician do
    get "dashboard", to: "dashboards#show", as: :dashboard
    resources :service_requests, only: [:index, :show] do
      member do
        patch :update_status
      end
      resources :service_notes, only: [:create]
    end
  end

  # Customer namespace
  namespace :customer do
    get "dashboard", to: "dashboards#show", as: :dashboard
    resources :service_requests, only: [:index, :show, :new, :create]
  end

  # Shared messaging (accessible by customer and assigned technician)
  resources :service_requests, only: [] do
    resources :messages, only: [:create]
  end

  # In-app notifications
  resources :notifications, only: [:index] do
    member do
      patch :mark_as_read
    end
  end
end
