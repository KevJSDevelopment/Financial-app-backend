class CreateTransactions < ActiveRecord::Migration[6.0]
  def change
    create_table :transactions do |t|
      t.float :value
      t.string :description
      t.string :date
      t.integer :plaid_account_id
      t.integer :transaction_category_id
      t.timestamps
    end
  end
end
