class PlaidAccount < ApplicationRecord
    belongs_to :user
    has_many :transactions

    def self.get_transactions(accounts_arr)
        accounts_arr.map do |account|
            accounts_hash = {account: account, transactions: account.transactions}
        end
    end
end
