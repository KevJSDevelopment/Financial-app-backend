class TransactionCategoriesController < ApplicationController

    def index
        transaction_categories = TransactionCategory.all.uniq
        if transaction_categories != []
            render json: {
                transaction_categories: transaction_categories,
                auth: true
            }
        else
            render json: {
                auth: false,
                message: "Unable to find transaction categories"
            }
        end
    end

    def show
        category = TransactionCategory.find(params[:id])
        byebug
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

end
