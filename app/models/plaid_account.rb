class PlaidAccount < ApplicationRecord
    belongs_to :user
    has_many :transactions

    def self.get_transactions(accounts_arr)
        accounts_arr.map do |account|
            accounts_hash = {account: account, transactions: account.get_categories(account.transactions)}
        end
    end
    
    def get_categories(transactions_arr)
        transactions_arr.map do |transaction|
            transaction_hash = {transaction: transaction, transaction_category: transaction.transaction_category}
        end
    end
end
