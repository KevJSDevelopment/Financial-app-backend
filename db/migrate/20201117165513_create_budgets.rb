class CreateBudgets < ActiveRecord::Migration[6.0]
  def change
    create_table :budgets do |t|
      t.string :name
      t.string :date_from
      t.string :date_to
      t.string :plan_type
      t.float :total
      t.integer :user_id

      t.timestamps
    end
  end
end
