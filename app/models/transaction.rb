class Transaction < ApplicationRecord
    belongs_to :plaid_account
    belongs_to :transaction_category

    def self.get_categories(transactions)
        transactions.map do |transaction|
            transaction_hash = {transaction_category: transaction.transaction_category, transaction: transaction}
        end
    end

end
