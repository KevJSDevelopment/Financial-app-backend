# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

User.delete_all
Budget.delete_all
Income.delete_all
Expense.delete_all
IncomeCategory.delete_all
ExpenseCategory.delete_all

budgets = ["food", "shopping", "yearly spending", "vacation", "weekends"]
food = ["pizza","chinese", "sushi", "groceries", "eatingOut"]
user = User.create(name: "user_good", password: "user_pass")
plan_types = ["simple","planned","full"]
i = 0
food_budget = Budget.create(name: budgets[i], date_from: "01/01/2020",  date_to: "01/01/2021", plan_type: "simple", total: 700.00 + i, user_id: user.id)
i += 1
(4).times do 
    Budget.create(name: budgets[i], date_from: "10/17/2020",  date_to: "10/17/2021", plan_type: "simple", total: 700.00 + i, user_id: user.id)
    i = i + 1
end

j = 0
(5).times do
    ExpenseCategory.create(name: food[j])
    j += 1
end

(100).times do
    exp_cat = ExpenseCategory.all.sample
    Expense.create(cost: 50.00, description: exp_cat.name, date: "10/18/2020", budget_id: food_budget.id, expense_category_id: exp_cat.id)
end
