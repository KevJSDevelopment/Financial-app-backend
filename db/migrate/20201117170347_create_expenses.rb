class CreateExpenses < ActiveRecord::Migration[6.0]
  def change
    create_table :expenses do |t|
      t.float :cost
      t.text :description
      t.string :date
      t.integer :budget_id
      t.integer :category_id

      t.timestamps
    end
  end
end
