FactoryBot.define do
  factory :stock do
    sequence(:company_name) { |n| "test_company_#{n}" }
    ticker_symbol do
      ('A'..'Z').to_a.shuffle[0..Random.rand(1..3)].join
    end
    country do
      %w[USA USA USA USA USA USA CHINA CHINA JAPAN][Random.rand(0..7)]
    end
    sector do
      ["Healthcare", "Basic Materials", "Financial", "Consumer Defensive", "Real Estate", "Industrials", "Technology", "Consumer Cyclical", "Communication Services", "Utilities", "Energy"][Random.rand(0..10)]
    end
    sequence(:url) { |n| "http://test_url_#{n}" }
  end
end
