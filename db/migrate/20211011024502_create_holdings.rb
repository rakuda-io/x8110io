class CreateHoldings < ActiveRecord::Migration[6.0]
  def change
    create_table :holdings do |t|
      t.float :quantity
      t.float :dividend_amount
      t.float :dividend_rate
      t.float :total_dividend_amount

      t.timestamps
    end
  end
end
