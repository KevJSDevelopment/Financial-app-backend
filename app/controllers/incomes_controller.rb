class IncomesController < ApplicationController

    def create
        income = Income.new(value: params[:value], description: params[:description], date: params[:date], budget_id: params[:budget_id], income_category_id: params[:income_category_id])
        if income.save
            render json: {
                income: income,
                auth: true,
                message: "Created Income"
            }
        else
            render json: {
                auth: false,
                message: income.error.full_messages
            }
        end
    end

end
