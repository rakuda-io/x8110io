class Stock < ApplicationRecord
  has_many :holdings, dependent: :destroy
  validates :ticker_symbol, presence: true
  extend CreateData

  # finviz.comから最新の株データを取得するためのメソッド
  def self.fetch_all_stocks_data
    @next_url = "" # ページネーションのURL保存
    page = 1 # for logger

    loop do
      Rails.logger.debug { "●●●●●● page #{page} ●●●●●●" } # for logger
      page += 1 # for logger

      # ページ内のデータを取得
      fetch_page_data

      # 取得したデータをデータベースに保存
      create_data_by_page

      # nextページネーションURLを保存
      fetch_next_page_url

      # nextページネーションがなかったらbreakさせる（最後のページネーションまで取り込み完了）
      if @next_link.text != "next"
        Rails.logger.debug { "Fetch data completed" } # for logger
        break
      end
    end
  end
end
