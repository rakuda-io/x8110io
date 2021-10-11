class CreateStocks < ActiveRecord::Migration[6.0]
  def change
    create_table :stocks do |t|
      t.string :company_name
      t.string :ticker_symbol
      t.string :country
      t.string :sector
      t.string :url

      t.timestamps
    end
  end
end
