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

      # 事前にサインインしておく
      before { post 'http://localhost:3000/api/auth', params: params }

      context 'ユーザーAがユーザーAの保有株一覧を取得しようとした場合' do
        before { get "#{base_url}#{user[:id]}/holdings", headers: tokens }

        it 'サインインしたユーザーの持っている保有株一覧が取得できること' do
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

      # 事前にサインインしておく
      before { post 'http://localhost:3000/api/auth', params: params }

      context 'ユーザーAがユーザーAの保有株をひとつ取得しようとした場合' do
        before { get "#{base_url}#{user[:id]}/holdings/#{user.holdings.first[:id]}", headers: tokens }

        it 'サインインしたユーザーの持っている保有株が取得できること' do
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

    context '正常' do
      # サインイン
      before { post 'http://localhost:3000/api/auth', params: params }

      context 'すべてのholding_paramsのリクエストが送信されているとき' do
        let(:holding_params) { { quantity: 1, user_id: user[:id], stock_id: new_stock[:id] } }

        it 'holding_paramsで送信した通りの株を新規登録できること' do
          post "#{base_url}#{user[:id]}/holdings", headers: tokens, params: holding_params
          expect(JSON.parse(response.body)['stock']['company_name']).to eq(new_stock[:company_name])
        end

        it '新規登録時に現在のdividend(配当金額)が登録出来ていること' do
          post "#{base_url}#{user[:id]}/holdings", headers: tokens, params: holding_params
          expect(JSON.parse(response.body)['dividend_amount']).not_to be_nil
        end

        it 'HTTPステータスが201であること' do
          post "#{base_url}#{user[:id]}/holdings", headers: tokens, params: holding_params
          expect(response).to have_http_status(:created)
        end

        # 成功のスタータスコードのテストよりも、新規登録によって件数が1件増えたことをテストするのもあり
        it '新規登録で1件のHoldingテーブルのレコードが増えること' do
          expect{post "#{base_url}#{user[:id]}/holdings", headers: tokens, params: holding_params}
            .to change{Holding.all.count}.by(+1)
        end
      end
    end

    context '異常' do
      context 'リクエストにstock_idが含まれていないとき' do
        let(:holding_params) { { quantity: 1, user_id: user[:id], stock_id: nil } }

        it '登録できないこと' do
          post "#{base_url}#{user[:id]}/holdings", headers: tokens, params: holding_params
          expect(JSON.parse(response.body)['errors']).to eq('You must fill out the fields!!')
        end

        it 'HTTPステータスが422である(処理ができない)こと' do
          post "#{base_url}#{user[:id]}/holdings", headers: tokens, params: holding_params
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context 'リクエストにquantityが含まれていないとき' do
        let(:holding_params) { { quantity: nil, user_id: user[:id], stock_id: new_stock[:id] } }

        it '登録できないこと' do
          post "#{base_url}#{user[:id]}/holdings", headers: tokens, params: holding_params
          expect(JSON.parse(response.body)['errors']).to eq('You must fill out the fields of Quantity')
        end

        it 'HTTPステータスが422である(処理ができない)こと' do
          post "#{base_url}#{user[:id]}/holdings", headers: tokens, params: holding_params
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context 'サインイン出来ていない場合' do
        let(:holding_params) { { quantity: 1, user_id: user[:id], stock_id: new_stock[:id] } }
        before { post "#{base_url}#{user[:id]}/holdings", params: holding_params }

        it '登録できないこと' do
          expect(JSON.parse(response.body)['errors']).to eq(["You need to sign in or sign up before continuing."])
        end

        it 'HTTPステータスが401である(アクセス権がない)こと' do
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end
  end

  describe '#update Action' do
    let(:tokens) { sign_in(params) }
    let(:params) { { email: user[:email], password: 'password' } }

    context '正常' do
      # サインイン
      before { post 'http://localhost:3000/api/auth', params: params }

      let(:update_params) { { quantity: 2 } }

      it 'update_paramsのquantity分だけholdingのquantityが増加していること' do
        expect{put "#{base_url}#{user[:id]}/holdings/#{user.holdings.first[:id]}", headers: tokens, params: update_params}
        .to change{user.holdings.first[:quantity]}.by(update_params[:quantity])
      end

      it 'HTTPステータスが200であること' do
        put "#{base_url}#{user[:id]}/holdings/#{user.holdings.first[:id]}", headers: tokens, params: update_params
        expect(response).to have_http_status(:ok)
      end
    end

    context '異常' do
      context 'quantityが未入力の場合' do
        let(:update_params) { { quantity: nil } }
        # サインイン
        before { post 'http://localhost:3000/api/auth', params: params }

        it '更新できないこと' do
          put "#{base_url}#{user[:id]}/holdings/#{user.holdings.first[:id]}", headers: tokens, params: update_params
          expect(JSON.parse(response.body)['errors']).to eq('You must fill out the fields!!')
        end

        it 'HTTPステータスが422である(処理ができない)こと' do
          put "#{base_url}#{user[:id]}/holdings/#{user.holdings.first[:id]}", headers: tokens, params: update_params
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context 'サインイン出来ていない場合' do
        let(:update_params) { { quantity: 2 } }
        before { put "#{base_url}#{user[:id]}/holdings/#{user.holdings.first[:id]}", params: update_params }

        it '登録できないこと' do
          expect(JSON.parse(response.body)['errors']).to eq(["You need to sign in or sign up before continuing."])
        end

        it 'HTTPステータスが401である(アクセス権がない)こと' do
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end
  end

  describe '#delete Action'
end
