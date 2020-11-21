class IncomeCategory < ApplicationRecord
    has_many :incomes

    validates :name, presence: true, uniqueness: { case_sensitive: false }
end
