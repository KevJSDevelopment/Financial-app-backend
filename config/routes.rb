Rails.application.routes.draw do
  resources :transaction_categories, only: [:create, :index, :update]
  resources :transactions, only: [:index, :update]
  resources :plaid_accounts, only: [:index]
  resources :incomes
  resources :expense_categories, only: [:create, :show]
  resources :income_categories, only: [:create, :show]
  resources :categories
  resources :expenses
  resources :budgets
  resources :users, only: [:create]

  patch "/expense_categories", to: "expense_categories#find_category"
  post "/login", to: "users#login"
  get "/link", to: "plaid_accounts#create_link_token"
  post "/get_access_token", to: "plaid_accounts#get_access_token"
  get "/users", to: "users#show"
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
