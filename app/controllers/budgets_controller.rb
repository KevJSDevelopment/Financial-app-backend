class BudgetsController < ApplicationController
    def index 
        token = request.headers["Authentication"].split(" ")[1]
        user = User.find(decode(token)["user_id"])
        budgets = Budget.where(user_id: user.id)
        # byebug
        render json: {
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
