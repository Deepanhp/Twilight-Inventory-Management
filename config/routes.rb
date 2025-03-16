Rails.application.routes.draw do
  # get "dashboard/index"
  devise_for :users
  resources :orders
  resources :members
  resources :users
  resources :items

  resources :users do
    member do
      delete :destroy_user
    end
  end

  root 'dashboard#index'
  get 'dashboard', to: 'dashboard#index'
  get '/update_chart', to: 'dashboard#update_chart'

  resources :items do
    get "fetch_data", :on => :collection
  end

  namespace :api do
    post 'place_order', to: 'orders#create'
    get 'orders_chart_data', to: 'orders#orders_chart_data'
    get 'category_orders_chart_data', to: 'orders#category_orders_chart_data'
    
    # Items controller routes
    resources :items, only: [] do
      collection do
        get 'by_category'
        get 'subcategories_by_category'
        get 'items_by_subcategory'
        get 'item_quantity'
      end
    end
  end

  resources :categories, only: [] do
    resources :sub_categories, only: [:index]
  end
  
  resources :sub_categories, only: [] do
    resources :items, only: :index
  end

  # root 'orders#index'
  get 'renew/:id' => 'orders#renew'
  get 'return/:id' => 'orders#disable'
  get 'past_orders' => 'orders#old'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  # root "posts#index"
end
