class Transaction < ApplicationRecord
    belongs_to :plaid_account
    belongs_to :transaction_category
end
