# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

User.delete_all
Category.delete_all
Budget.delete_all
Expense.delete_all

budgets = ["food", "shopping", "yearly spending", "vacation", "weekends"]
user = User.create(name: "user_good", password: "user_pass")

i = 0
(5).times do 
    Budget.create(name: budgets[i], date_from: "10/17/2020",  date_to: "10/17/2021", total: 700.00 + i, user_id: user.id)
    i = i + 1
end