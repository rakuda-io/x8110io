class Holding < ApplicationRecord
  belongs_to :stock
  belongs_to :user

  # 個別にdividendを取得するためのインスタンスメソッド
  def fetch_current_dividend
    agent = Mechanize.new
    url = agent.get(Stock.find(stock_id).url)
    current_dividend_amount = url.search("td")[106].text.to_f
    current_dividend_rate = url.search("td")[118].text.to_f
    update!(
      dividend_amount: current_dividend_amount,
      dividend_rate: current_dividend_rate,
      total_dividend_amount: current_dividend_amount * quantity
    )
  end

  # 同じstock_idが該当userのholdingsに存在するか？を返すインスタンスメソッド
  def same_stock_id_exist?
    Holding.where(user_id: user_id).pluck(:stock_id).include?(stock_id)
  end

  # メンテナンス用
  # 全Holdingsにまとめて最新情報のdividendを取得するためのクラスメソッド
  def self.fetch_all_current_dividends
    agent = Mechanize.new
    holdings = Holding.all
    holdings.map do |holding|
      url = agent.get(holding.stock.url)
      current_dividend_amount = url.search("td")[106].text.to_f
      current_dividend_rate = url.search("td")[118].text.to_f
      holding.update!(
        dividend_amount: current_dividend_amount,
        dividend_rate: current_dividend_rate,
        total_dividend_amount: current_dividend_amount * holding.quantity
      )
    end
  end
end
