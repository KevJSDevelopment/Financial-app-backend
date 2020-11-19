class Income < ApplicationRecord
    belongs_to :budget
    belongs_to :income_category
end
