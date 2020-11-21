class IncomeCategoriesController < ApplicationController

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
end
