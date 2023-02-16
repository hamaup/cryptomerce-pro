Rails.application.routes.draw do
  require 'sidekiq/web'
  scope '(:locale)', locale: /#{I18n.available_locales.map(&:to_s).join('|')}/ do
    devise_for :admins, controllers: {
      sessions: 'admin/sessions'
    }
    devise_for :customers, controllers: {
      sessions: 'customer/sessions',
      registrations: 'customer/registrations'
    }
    root to: 'pages#home'
    namespace :admin do
      root to: 'pages#home'
      resources :products, only: %i[index show new create edit update]
      resources :orders, only: %i[show update]
      resources :customers, only: %i[index show update]
      authenticate :admin do
        mount Sidekiq::Web => '/sidekiq'
      end
    end
    scope module: :customer do
      resources :products, only: %i[index show]
      resources :cart_items, only: %i[index create destroy] do
        member do
          patch 'increase'
          patch 'decrease'
        end
      end
      resources :checkouts, only: [:create]
      resources :webhooks, only: [:create] do
        collection do
          get 'confirm'
          get 'success'
          get 'failure'
          post 'update_payment_status'
        end
      end
      resources :orders, only: %i[index show] do
        collection do
          get 'success'
          get 'failure'
        end
      end
      resources :customers do
        collection do
          get 'confirm_withdraw'
          patch 'withdraw'
        end
      end
    end
  end
  get '/up/', to: 'up#index', as: :up
  get '/up/databases', to: 'up#databases', as: :up_databases
end
