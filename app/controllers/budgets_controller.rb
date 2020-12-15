require 'date'
class BudgetsController < ApplicationController

    def bar_comparison
        token = request.headers["Authentication"].split(" ")[1]
        user = User.find(decode(token)["user_id"])
        plan = params[:plan]
        accounts = params[:accounts]
        
        income_keys = []
        expense_keys = []

        income_category_sums = plan["incomeInfo"].map do |income_obj|
            incomeSum = 0.00
            income_obj["incomes"].each do |income|
                incomeSum += income["value"]
            end
            hash = {category: income_obj["cat"]["name"], value: incomeSum}
            hash
        end
        
        expense_category_sums = plan["expenseInfo"].map do |expense_obj|
            expenseSum = 0.00
            expense_obj["expenses"].each do |expense|
                expenseSum += expense["cost"]
            end
            hash = {category: expense_obj["cat"]["name"], value: expenseSum}
            hash
        end

        actual_incomes = {}
        actual_expenses = {}
        accounts.map do |account|
            account["transactions"].each do |transaction|
                if transaction["transaction"]["value"] >= 0
                    if !income_keys.include? transaction["transaction_category"]["name"]
                        income_keys.push(transaction["transaction_category"]["name"])
                    end
                    if !actual_incomes[transaction["transaction_category"]["name"]]
                        actual_incomes[transaction["transaction_category"]["name"]] = transaction["transaction"]["value"]
                    else
                        actual_incomes[transaction["transaction_category"]["name"]] += transaction["transaction"]["value"]
                    end
                else
                    if !expense_keys.include? transaction["transaction_category"]["name"]
                        expense_keys.push(transaction["transaction_category"]["name"])
                    end
                    if !actual_expenses[transaction["transaction_category"]["name"]]
                        actual_expenses[transaction["transaction_category"]["name"]] = (transaction["transaction"]["value"] * -1)
                    else
                        actual_expenses[transaction["transaction_category"]["name"]] -= transaction["transaction"]["value"]
                    end
                end
            end
        end

        income_keys.push("Other")
        expense_keys.push("Other")
        income_data = income_keys.map do |key|
            income_hash = {
                "Category": key,
                "Expected": 0.00,
                "ExpectedColor": "hsl(90, 70%, 50%)",
                "Actual": 0.00,
                "ActualColor": "hsl(122, 70%, 50%)"
            }
            income_category_sums.each do |object|
                if income_keys.include? object[:category]
                    if object[:category] == key
                        income_hash[:Expected] = object[:value]
                    end
                elsif key == "Other"
                    income_hash[:Expected] = object[:value]
                end
            end
            if key != "Other"
                income_hash[:Actual] = actual_incomes[key]
            end
            income_hash
        end

        expense_data = expense_keys.map do |key|
            expense_hash = {
                "Category": key,
                "Expected": 0.00,
                "Actual": 0.00
            }
            expense_category_sums.each do |object|
                if expense_keys.include? object[:category]
                    if object[:category] == key
                        expense_hash[:Expected] = object[:value]
                    end
                elsif key == "Other"
                    expense_hash[:Expected] = object[:value]
                end
            end
            if key != "Other"
                expense_hash[:Actual] = actual_expenses[key]
            end
            expense_hash
        end
        

        inc_keys = ["Actual","Expected"]
        exp_keys = ["Actual","Expected"]

        render json: {
            incomeData: income_data,
            expenseData: expense_data,
            incomeKeys: inc_keys,
            expenseKeys: exp_keys
        }
    end

    def line_comparison
        token = request.headers["Authentication"].split(" ")[1]
        user = User.find(decode(token)["user_id"])
        plan = params[:plan]
        accounts = params[:accounts]

        startDate = Date.strptime(plan["budget"]["date_from"], "%m/%d/%Y")
        endDate = Date.strptime(plan["budget"]["date_to"], "%m/%d/%Y")

        day_difference = ((endDate - startDate) / 5).to_f.ceil

        keys = []

        lastDate = startDate
        (4).times do
            newDate = (lastDate + day_difference)
            keys.push("#{lastDate.strftime('%m/%d/%Y')} - #{newDate.strftime('%m/%d/%Y')}")
            lastDate = newDate
        end

        keys.push("#{lastDate.strftime('%m/%d/%Y')} - #{endDate.strftime('%m/%d/%Y')}")

        
        expected_income_hash = {
            "id": "Expected",
            "color": "hsl(11, 70%, 50%)",
            "data": []
        }
        expected_expense_hash = {
            "id": "Expected",
            "color": "hsl(11, 70%, 50%)",
            "data": []
        }
        actual_income_hash = {
            "id": "Actual",
            "color": "hsl(261, 70%, 50%)",
            "data": []
        }
        actual_expense_hash = {
            "id": "Actual",
            "color": "hsl(261, 70%, 50%)",
            "data": []
        }
        keys.map do |key|
            key_arr = key.split("-")
            key_start = Date.strptime(key_arr[0].strip, "%m/%d/%Y")
            key_end = Date.strptime(key_arr[1].strip, "%m/%d/%Y")
            
            income_sum = 0.00
            plan["incomeInfo"].map do |income_obj|
                income_obj["incomes"].each do |income|
                    
                    if Date.strptime(income["date"], "%m/%d/%Y") >= key_start && Date.strptime(income["date"], "%m/%d/%Y") <= key_end
                        income_sum += income["value"]
                    end
                end
            end
            income_hash = {
                "x": key,
                "y": income_sum
            }
            expected_income_hash[:data].push(income_hash)

            expense_sum = 0.00
            plan["expenseInfo"].map do |expense_obj|
                expense_obj["expenses"].each do |expense|
                    if Date.strptime(expense["date"], "%m/%d/%Y") >= key_start && Date.strptime(expense["date"], "%m/%d/%Y") <= key_end
                        expense_sum += expense["cost"]
                    end
                end
            end
            expense_hash = {
                "x": key,
                "y": expense_sum
            }
            expected_expense_hash[:data].push(expense_hash)

            actual_income_sum = 0.00
            actual_expense_sum = 0.00
            accounts.map do |account|
                account["transactions"].each do |transaction|
                    date_arr = transaction["transaction"]["date"].split("-")
                    date_formatted = [date_arr[1],date_arr[2], date_arr[0]].join("/")
                    
                    if Date.strptime(date_formatted, "%m/%d/%Y") >= key_start && Date.strptime(date_formatted, "%m/%d/%Y") <= key_end 
                        if transaction["transaction"]["value"] >= 0
                            actual_income_sum += transaction["transaction"]["value"]
                        else
                            actual_expense_sum -= transaction["transaction"]["value"]
                        end
                    end
                end
            end

            actual_income = {
                "x": key,
                "y": actual_income_sum
            }
            actual_expense = {
                "x": key,
                "y": actual_expense_sum
            }

            actual_income_hash[:data].push(actual_income)
            actual_expense_hash[:data].push(actual_expense)
        end

        income_data = [actual_income_hash, expected_income_hash]
        expense_data = [ actual_expense_hash, expected_expense_hash]

        

        render json: {
            incomeData: income_data,
            expenseData: expense_data
        }
    end

    def index 
        token = request.headers["Authentication"].split(" ")[1]
        user = User.find(decode(token)["user_id"])
        budgets = Budget.where(user_id: user.id)
        
        render json: {
            auth: true,
            budgets: budgets
        }
    end

    def create
        token = request.headers["Authentication"].split(" ")[1]
        user = User.find(decode(token)["user_id"])
        budget = Budget.new(name: params[:name], plan_type: params[:type], date_from: params[:date_from], date_to: params[:date_to], total: 0.00, user_id: user.id)
        if budget.save
            render json: {
                budget: budget,
                expenses: budget.expenses,
                auth: true,
                info: "New Plan was created"
            }
        else
            render json: {
                info: budget.errors.full_messages,
                auth: false
            }
        end
    end

    def show
        budget = Budget.find(params[:id])
        
        if budget
            render json: {
                budget: budget,
                expenseInfo: budget.get_expense_info(budget.expenses),
                incomeInfo: budget.get_income_info(budget.incomes),
                auth: true
            }
        else
            render json: {
                auth: false
            }
        end
    end

    def update
        budget = Budget.find(params[:id])
        if budget
            budget.update(total: params[:total])
            render json: {
                budget: budget,
                auth: true,
                expenseInfo: budget.get_expense_info(budget.expenses)
            }
        else
            render json: {
                auth: false
            }
        end
    end

    def destroy
        budget = Budget.find(params[:id])
        name = budget.name
        if budget
            budget.destroy()
            render json: {
                auth: true,
                message: "Successfully deleted #{name} financial plan"
            }
        else 
            render json: {
                auth: false,
                message: "Unable to find the plan you want to remove"
            }
        end
    end

end
