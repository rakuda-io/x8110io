require 'rails_helper'
require 'net/http'

# 保有株一覧のJSON出力のテスト
RSpec.describe 'Holdings API', type: :request do
  let(:base_url) { 'http://localhost:3000/api/users/' }
  let!(:stock) { create(:stock) }
  let!(:user) { create(:user) }
  let!(:another_user) { create(:user) }
  let!(:user_holdings) { create_list(:holding, 3, user_id: user[:id], stock_id: stock[:id]) }
  let!(:another_user_holdings) { create_list(:holding, 3, user_id: another_user[:id], stock_id: stock[:id]) }
  # 事前にログインしておく
  before { post 'http://localhost:3000/api/auth', params: params }

  describe '#index Action' do
    context '正常' do
      let(:tokens) { sign_in(params) }
      let(:params) { { email: user[:email], password: 'password' } }

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

        it '保有株一覧が取得できないこと' do
          expect(JSON.parse(response.body)['errors']).to include('Access denied! No match your user id')
        end

        it 'HTTPステータスが401である(アクセス権がない)こと' do
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end

    context '異常' do
      context 'token情報がヘッダーに無い場合' do
        before { get "#{base_url}#{user[:id]}/holdings" }

        it '保有株一覧が取得できないこと' do
          expect(JSON.parse(response.body)['errors']).to eq(["You need to sign in or sign up before continuing."])
        end

        it 'HTTPステータスが401である(アクセス権がない)こと' do
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end
  end
end
