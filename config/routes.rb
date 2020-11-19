Rails.application.routes.draw do
  resources :incomes
  resources :expense_categories
  resources :iexpense_categories
  resources :income_categories
  resources :categories
  resources :expenses
  resources :budgets
  resources :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
