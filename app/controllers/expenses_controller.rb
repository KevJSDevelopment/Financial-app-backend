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
                auth: false,
                message: expense.error.full_messages
            }
        end
    end

    def update
        expense = Expense.find(params[:id])
        # byebug
        if expense
            expense.update(expense_category_id: params[:expense_category_id])
            render json: {
                expense: expense,
                auth: true,
                message: "Expense #{expense.id} Updated"
            }
        else
            render json: {
                auth: false,
                message: expense.errors.full_messages
            }
        end
    end
end
