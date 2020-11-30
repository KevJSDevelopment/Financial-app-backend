class BudgetsController < ApplicationController

    def bar_comparison
        token = request.headers["Authentication"].split(" ")[1]
        user = User.find(decode(token)["user_id"])
        plan = params[:plan]
        accounts = params[:accounts]
        # byebug
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
                        actual_expenses[transaction["transaction_category"]["name"]] = transaction["transaction"]["value"]
                    else
                        actual_expenses[transaction["transaction_category"]["name"]] += transaction["transaction"]["value"]
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
        # byebug

        inc_keys = ["Expected", "Actual"]
        exp_keys = ["Expected", "Actual"]

        render json: {
            incomeData: income_data,
            expenseData: expense_data,
            incomeKeys: inc_keys,
            expenseKeys: exp_keys
        }
    end

    def line_comparison

    end

    def index 
        token = request.headers["Authentication"].split(" ")[1]
        user = User.find(decode(token)["user_id"])
        budgets = Budget.where(user_id: user.id)
        # byebug
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
        # byebug
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
