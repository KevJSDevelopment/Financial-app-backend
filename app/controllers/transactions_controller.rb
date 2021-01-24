class TransactionsController < ApplicationController

    def index
        transactions = Transaction.where(plaid_account_id: params[:plaid_account_id])
        render json: {
            auth: true,
            transactions: Transaction.get_categories(transactions)
        }
    end

end
