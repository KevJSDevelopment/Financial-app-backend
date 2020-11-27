class PlaidAccount < ApplicationRecord
    belongs_to :user
    has_many :transactions
end
