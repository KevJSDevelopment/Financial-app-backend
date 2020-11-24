Rails.application.routes.draw do
  resources :incomes
  resources :expense_categories, only: [:create, :show]
  resources :income_categories, only: [:create]
  resources :categories
  resources :expenses
  resources :budgets
  resources :users, only: [:create]

  patch "/expense_categories", to: "expense_categories#find_category"
  post "/login", to: "users#login"
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
