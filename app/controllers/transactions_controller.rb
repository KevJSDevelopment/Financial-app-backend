class TransactionsController < ApplicationController

    def index
        transactions = Transaction.where(plaid_account_id: params[:plaid_account_id])
        render json: {
            auth: true,
            transactions: transactions
        }
    end
    
    def update

    end

end
