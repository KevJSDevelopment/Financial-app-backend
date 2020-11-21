class ExpensesController < ApplicationController
    
    def create
        expense = Expense.new(cost: params[:cost], description: params[:description], date: params[:date], budget_id: params[:budget_id], expense_category_id: params[:expense_category_id])
        if expense.save
            render json: {
                expense: expense,
                auth: true,
                message: "Created expense"
            }
        else
            render json: {
                auth: true,
                message: expense.error.full_messages
            }
        end
    end
end
