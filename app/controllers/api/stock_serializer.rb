class StockSerializer < ActiveModel::Serializer
  attributes :id, :ticker_symbol, :company_name, :country, :sector, :url
end
