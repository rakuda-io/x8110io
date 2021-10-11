FactoryBot.define do
  factory :holding do
    quantity { Random.rand(0.1..20.0).floor(1) }
    dividend_amount { Random.rand(1.0..20.0).floor(1) }
    dividend_rate { Random.rand(0.1..5.0).floor(1) }
    total_dividend_amount { quantity * dividend_amount }

    # 関連付けがあるモデルを同時に生成
    association :user
    association :stock
  end
end
