class CreatePlaidAccounts < ActiveRecord::Migration[6.0]
  def change
    create_table :plaid_accounts do |t|
      t.integer :user_id
      t.string :p_access_token
      t.string :p_item_id
      t.string :p_institution
      t.timestamps
    end
  end
end
