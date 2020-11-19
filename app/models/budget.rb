class Budget < ApplicationRecord
    has_many :expenses
    has_many :incomes
    belongs_to :user

    def get_expense_info(expenses_arr)
        # byebug
        if expenses_arr.length > 0
            categories = expenses_arr.map do |expense|
                { cat: expense.expense_category, expenses: expense.expense_category.expenses }
            end
            # byebug
            return categories.uniq { |e| e[:cat] }
        else
            categories = []
            return categories
        end
    end
end
