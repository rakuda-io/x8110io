module FetchDividend
  extend ActiveSupport::Concern

  included do
    # 個別にdividendを取得するためのインスタンスメソッド
    def fetch_current_dividend
      agent = Mechanize.new
      url = agent.get(Stock.find(@new_holding.stock_id).url)
      current_dividend_amount = url.search("td")[106].text.to_f
      current_dividend_rate = url.search("td")[118].text.to_f
      @new_holding.update!(
        dividend_amount: current_dividend_amount,
        dividend_rate: current_dividend_rate,
        total_dividend_amount: current_dividend_amount * @new_holding.quantity
      )
    end
  end
end
