require 'rails_helper'
require 'net/http'

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
      let!(:new_stock) { create(:stock) }

      # 事前にログインしておく
      before { post 'http://localhost:3000/api/auth', params: params }

      context 'サインイン出来ている場合' do
        let(:holding_params) { { quantity: 1, user_id: user[:id], stock_id: new_stock[:id] } }
        # before { post "#{base_url}#{user[:id]}/holdings", headers: tokens, params: holding_params }

        it '新しい株を保有株に新規登録できること' do
          post "#{base_url}#{user[:id]}/holdings", headers: tokens, params: holding_params
          expect(JSON.parse(response.body)).to eq('')
        end
      end
    end
  end
  describe '#update Action'
  describe '#delete Action'
end
