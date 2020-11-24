class ExpenseCategoriesController < ApplicationController
    def create
        expense_category = ExpenseCategory.new(name: params[:name])
        if expense_category.save
            render json: {
                expense_category: expense_category,
                auth: true,
                message: "Your new category was added"
            }
        else
            render json: {
                auth: false,
                message: expense_category.errors.full_messages
            } 
        end
    end

    def show
        expense_category = ExpenseCategory.find(params[:id])
        if expense_category
            render json: {
                expense_category: expense_category,
                auth: true,
                message: "Expense category found"
            }
        else
            render json: {
                auth: false,
                message: "Could not find expense Category with id #{params[:id]}"
            }
        end
    end

    def find_category
        expense_category = ExpenseCategory.find_by(name: params[:name])
        if expense_category
            render json: {
                expense_category: expense_category,
                auth: true,
                message: "Category found"
            }
        else
            render json: {
                auth: false,
                message: "Cannot find category"
            }
        end
    end
end
