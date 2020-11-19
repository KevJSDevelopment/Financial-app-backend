class BudgetsController < ApplicationController
    def index 
        budgets = Budget.all
        render json: {
            budgets: budgets
        }
    end

    def create
        budget = Budget.new(name: params[:name], plan_type: params[:type], date_from: params[:date_from], date_to: params[:date_to], total: 0.00, user_id: User.first.id)
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
                auth: true
            }
        else
            render json: {
                auth: false
            }
        end
    end
end
