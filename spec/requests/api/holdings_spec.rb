require 'rails_helper'
# require 'webmock/rspec'

# 保有株一覧のJSON出力のテスト
RSpec.describe 'Holdings API', type: :request do
  let!(:stock) { create(:stock) }
  let!(:user) { create(:user) }
  let!(:another_user) { create(:user) }
  let!(:user_holdings) { create_list(:holding, 3, user_id: user[:id], stock_id: stock[:id]) }
  let!(:another_user_holdings) { create_list(:holding, 3, user_id: another_user[:id], stock_id: stock[:id]) }
  let(:base_url) { 'http://localhost:3000/api/users/' }

  describe '#index Action' do
    context '正常' do
      let(:tokens) { sign_in(params) }
      let(:params) { { email: user[:email], password: 'password' } }

      # 事前にログインしておく
      before { post 'http://localhost:3000/api/auth', params: params }

      context 'ユーザーAがユーザーAの保有株一覧を取得しようとした場合' do
        before { get "#{base_url}#{user[:id]}/holdings", headers: tokens }

        it 'ログインしたユーザーの持っている保有株一覧が取得できること' do
          expect(JSON.parse(response.body)[0]['user']['name']).to eq(user[:name])
        end

        it 'HTTPステータスが200であること' do
          expect(response).to have_http_status(:ok)
        end
      end

      context 'ユーザーAがユーザーBの保有株一覧を取得しようとした場合' do
        before { get "#{base_url}#{another_user[:id]}/holdings", headers: tokens }

        it '権限がなく保有株一覧が取得できないこと' do
          expect(JSON.parse(response.body)['errors']).to include('Your access denied! No match your user id')
        end

        it 'HTTPステータスが401である(アクセス権がない)こと' do
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end

    context '異常' do
      context 'token情報がヘッダーに無い場合' do
        before { get "#{base_url}#{user[:id]}/holdings" }

        it '権限がなく保有株一覧が取得できないこと' do
          expect(JSON.parse(response.body)['errors']).to eq(["You need to sign in or sign up before continuing."])
        end

        it 'HTTPステータスが401である(アクセス権がない)こと' do
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end
  end

  describe '#show Action' do
    context '正常' do
      let(:tokens) { sign_in(params) }
      let(:params) { { email: user[:email], password: 'password' } }

      # 事前にログインしておく
      before { post 'http://localhost:3000/api/auth', params: params }

      context 'ユーザーAがユーザーAの保有株をひとつ取得しようとした場合' do
        before { get "#{base_url}#{user[:id]}/holdings/#{user.holdings.first[:id]}", headers: tokens }

        it 'ログインしたユーザーの持っている保有株が取得できること' do
          expect(JSON.parse(response.body)[0]['user']['id']).to eq(user[:id])
        end

        it 'HTTPステータスが200であること' do
          expect(response).to have_http_status(:ok)
        end
      end

      context 'ユーザーAがユーザーBの保有株をひとつ取得しようとした場合' do
        before { get "#{base_url}#{another_user[:id]}/holdings/#{another_user.holdings.first[:id]}", headers: tokens }

        it '権限がなく保有株が取得できないこと' do
          expect(JSON.parse(response.body)['errors']).to include('Your access denied! No match your user id')
        end

        it 'HTTPステータスが401である(アクセス権がない)こと' do
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end

    context '異常' do
      context 'token情報がヘッダーに無い場合' do
        before { get "#{base_url}#{user[:id]}/holdings/#{user.holdings.first[:id]}" }

        it '権限がなく保有株一覧が取得できないこと' do
          expect(JSON.parse(response.body)['errors']).to eq(["You need to sign in or sign up before continuing."])
        end

        it 'HTTPステータスが401である(アクセス権がない)こと' do
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end
  end

  describe '#create Action' do
    context '正常' do
      let(:tokens) { sign_in(params) }
      let(:params) { { email: user[:email], password: 'password' } }
      # factory_botのstockを実際にスクレイピング出来るデータにオーバーライド
      let!(:new_stock) do
        create(:stock,
               company_name: "SPDR Portfolio S&P 500 High Dividend ETF",
               ticker_symbol: "SPYD",
               country: "USA",
               sector: "Financial",
               url: "https://finviz.com/quote.ashx?t=SPYD&ty=c&p=d&b=1")
      end

      # 事前にログインしておく
      before { post 'http://localhost:3000/api/auth', params: params }

      context 'サインイン出来ている場合' do
        let(:holding_params) { { quantity: 1, user_id: user[:id], stock_id: new_stock[:id] } }
        before { post "#{base_url}#{user[:id]}/holdings", headers: tokens, params: holding_params }

        it 'paramsで送信した通りの株を新規登録できること' do
          expect(JSON.parse(response.body)['stock']['company_name']).to eq(new_stock[:company_name])
        end

        it '新規登録時に現在のdividend(配当金額)が登録出来ていること' do
          expect(JSON.parse(response.body)['dividend_amount']).not_to be_nil
        end

        it 'HTTPステータスが201であること' do
          expect(response).to have_http_status(:created)
        end
        # 成功のスタータスコードのテストよりも、新規登録によって件数が1件増えたことをテストするのもあり

        # 作れなかった時
        #
      end

      context 'サインイン出来ていない場合'
    end

    context '異常'
  end

  describe '#update Action'
  describe '#delete Action'
end
