module CreateData
  extend ActiveSupport::Concern

  def fetch_page_data
    @agent = Mechanize.new
    @current_page = @agent.get("https://finviz.com/screener.ashx?v=111#{@next_url}")
    @tickers = @current_page.search(".screener-link-primary").map(&:text)
    @urls = @current_page.search(".screener-body-table-nw a").map { |url| url.get_attribute('href') }.uniq
  end

  def create_data_by_page
    @tickers.zip(@urls) do |ticker, url|
      detailed_page = @agent.get(url)
      create!(
        ticker_symbol: ticker,
        url: "https://finviz.com/#{url}",
        company_name: detailed_page.search("td")[29].text,
        sector: detailed_page.search("td")[30].search("a").first.text,
        country: detailed_page.search("td")[30].search("a").last.text
      )
    end
  end

  # 次ページのリンクを取得して変数next_linkに次ページURLの必要部分のみを正規表現で取り出し代入
  def fetch_next_page_url
    @next_link = @current_page.at(".screener_pagination a:last-child")
    @next_url = @next_link.get_attribute('href').match(/&.+/).to_s if @next_link.text == "next"
  end
end
