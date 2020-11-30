class IncomeCategoriesController < ApplicationController

    def create
        income_category = IncomeCategory.new(name: params[:name])
        if income_category.save
            render json: {
                income_category: income_category,
                auth: true,
                message: "Your new category was added"
            }
        else
            render json: {
                auth: false,
                message: income_category.errors.full_messages
            } 
        end
    end
    
    def show
        income_category = IncomeCategory.find(params[:id])
        if income_category
            render json: {
                income_category: income_category,
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
        income_category = IncomeCategory.find_by(name: params[:name])
        if income_category
            render json: {
                income_category: income_category,
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
