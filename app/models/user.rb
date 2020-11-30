class User < ApplicationRecord
    has_many :budgets
    has_many :plaid_accounts
    has_secure_password

    validates :name, uniqueness: true, presence: true
    validates :name, uniqueness: { case_sensitive: false }
end
