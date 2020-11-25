class Expense < ApplicationRecord
    belongs_to :expense_category
    belongs_to :budget

    validates :cost, presence: true
end
