Rails.application.routes.draw do
  devise_for :users, skip: :all
  devise_scope :user do
    get "login", to: "users/sessions#new", as: :new_user_session
    post "login", to: "users/sessions#create", as: :user_session
    delete "logout", to: "users/sessions#destroy", as: :destroy_user_session
    get "signup", to: "users/registrations#new", as: :new_user_registration
    post "signup", to: "users/registrations#create", as: :user_registration
  end

  root "pages#home"

  get "about", to: "pages#about"
  get "contact", to: "pages#contact"
  get "shipping", to: "pages#shipping"
  get "returns", to: "pages#returns"
  get "faq", to: "pages#faq"
  get "privacy", to: "pages#privacy"
  get "terms", to: "pages#terms"

  get "shop", to: "products#index"
  get "new-arrivals", to: "products#new_arrivals", as: :new_arrivals
  get "best-sellers", to: "products#best_sellers", as: :best_sellers
  get "sale", to: "products#sale"
  resources :products, only: [:show], param: :slug

  resource :cart, only: [:show, :destroy] do
    post :add, on: :collection
    post :buy_now, on: :collection
    patch :increase, on: :member
    patch :decrease, on: :member
    patch :update_item, on: :member
    delete :remove_item, on: :member
  end

  resource :checkout, only: [:show, :create]
  resources :orders, only: [:index, :show] do
    get :confirmation, on: :member
  end

  resource :account, only: [:show, :edit, :update], controller: "accounts"
  resources :addresses, path: "account/addresses", except: [:show]

  namespace :admin do
    root to: "dashboard#index"
    get "dashboard", to: "dashboard#index"

    resources :products, except: [:show] do
      member do
        patch :toggle_active
        delete :remove_image
      end
    end
    resources :categories, except: [:show]
    resources :customers, only: [:index, :show]
    resources :orders, only: [:index, :show, :update]
    get "inventory", to: "inventory#index"
    patch "inventory/:id", to: "inventory#update", as: :update_inventory
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
