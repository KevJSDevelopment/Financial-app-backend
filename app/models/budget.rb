class Budget < ApplicationRecord
    has_many :expenses
    belongs_to :user
end
