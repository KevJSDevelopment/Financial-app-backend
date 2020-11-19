class CreateIncomes < ActiveRecord::Migration[6.0]
  def change
    create_table :incomes do |t|
      t.float :value
      t.text :description
      t.string :date
      t.integer :budget_id
      t.integer :income_category_id
      t.timestamps
    end
  end
end
