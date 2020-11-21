class ExpenseCategory < ApplicationRecord
    has_many :expenses

    validates :name, presence: true, uniqueness: { case_sensitive: false }
end
