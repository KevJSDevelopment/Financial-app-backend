class Budget < ApplicationRecord
    has_many :expenses
    has_many :incomes
    belongs_to :user

    def get_expense_info(expensesArr)
        categories = expensesArr.map do |expense|
            { cat: expense.expense_category, expenses: expense.expense_category.expenses }
        end
        # byebug
        return categories.uniq { |e| e[:cat] }
    end
end
