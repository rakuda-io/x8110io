class SortByHoldings < ActiveRecord::Migration[6.0]
  def change
    change_column :holdings, :user_id, :bigint, after: :id
    change_column :holdings, :stock_id, :bigint, after: :user_id
  end
end
