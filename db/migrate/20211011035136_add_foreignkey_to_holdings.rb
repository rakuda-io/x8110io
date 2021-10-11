class AddForeignkeyToHoldings < ActiveRecord::Migration[6.0]
  def change
    add_reference :holdings, :user, foreign_key: true
    add_reference :holdings, :stock, foreign_key: true
  end
end
