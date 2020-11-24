class ExpenseCategory < ApplicationRecord
    has_many :expenses

    validates :name, presence: true, uniqueness: true 

end
