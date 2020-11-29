class TransactionCategoriesController < ApplicationController

    def create

    end

    def index

    end

    def show
        category = TransactionCategory.find(params[:id])
        if category
            render json: {
                transaction_category: category,
                auth: true
            }
        else
            render json: {
                auth: false,
                message: "Could not find category"
            }
        end
    end

    def update

    end

end
