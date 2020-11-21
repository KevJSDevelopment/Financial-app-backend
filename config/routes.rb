Rails.application.routes.draw do
  resources :incomes
  resources :expense_categories, only: [:create]
  resources :income_categories, only: [:create]
  resources :categories
  resources :expenses
  resources :budgets
  resources :users

  patch "/expense_categories", to: "expense_categories#find_category"
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
