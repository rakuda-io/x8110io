class AddNullfalseToHoldings < ActiveRecord::Migration[6.0]
  def up
    change_column :holdings, :user_id, :bigint, null: false
    change_column :holdings, :stock_id, :bigint, null: false
  end

  def down
    change_column :holdings, :user_id, :bigint
    change_column :holdings, :stock_id, :bigint
  end
end
