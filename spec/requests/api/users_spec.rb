require 'rails_helper'

# devise_token_authによるユーザー認証機能のテスト
RSpec.describe 'User Authorization', type: :request do
  let(:base_url) { 'http://localhost:3000/api/auth/' }

  describe 'Sign up Function' do
    before { post base_url, params: params }

    context '正常' do
      let(:user) { create(:user) }
      let(:params) { { name: 'test_user', email: 'test@test.com', password: 'password', password_confirmation: 'password' } }

      it 'ユーザーが新規登録できること' do
        expect(user).to be_present
      end

      it 'HTTPステータスが200であること' do
        expect(response).to have_http_status(:ok)
      end
    end

    context '異常' do
      let(:params) { { name: 'test', email: 'test@test.com' } }

      it 'ユーザーが新規登録できないこと' do
        expect(JSON.parse(response.body)['errors']['full_messages']).to eq(["Password can't be blank"])
      end

      it 'HTTPステータスが422である(処理ができない)こと' do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'Sign in Function' do
    before { post "#{base_url}sign_in", params: params }

    context '正常' do
      let(:user) { create(:user) }
      let(:params) { { email: user[:email], password: 'password' } }
      it 'ログインしようとしたユーザーでログイン出来ること' do
        expect(JSON.parse(response.body)['data']['email']).to eq(user[:email])
      end

      it 'HTTPステータスが200であること' do
        expect(response).to have_http_status(:ok)
      end

      it 'ヘッダーに正しいトークン情報が付与されていること' do
        tokens = sign_in(params)
        expect(response.headers['access-token']).to eq(tokens['access-token'])
      end
    end

    context '異常' do
      let(:user) { create(:user) }
      let(:params) { { email: user[:email] } }
      it 'ログインしようとしたユーザーでログイン出来ないこと' do
        expect(JSON.parse(response.body)['errors']).to eq(["Invalid login credentials. Please try again."])
      end

      it 'HTTPステータスが401である(アクセス権がない)こと' do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'Sign out Function' do
    let!(:user) { create(:user) }
    let(:tokens) { sign_in(params) }
    let(:params) { { email: user[:email], password: 'password' } }
    # sign_inしている状態を作る
    before { post "#{base_url}sign_in", params: params }

    context '正常' do
      it 'ログインしたユーザーがログアウト出来ること' do
        delete "#{base_url}sign_out", headers: tokens
        expect(JSON.parse(response.body)['success']).to eq(true)
      end

      it 'HTTPステータスが200であること' do
        expect(response).to have_http_status(:ok)
      end
    end

    context '異常' do
      before { delete "#{base_url}sign_out", headers: nil }

      it 'ログインしたユーザーがログアウト出来ないこと' do
        expect(JSON.parse(response.body)['errors']).to eq(["User was not found or was not logged in."])
      end

      it 'HTTPステータスが404である(ページが見つからない)こと' do
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'Edit user Function' do
    let!(:user) { create(:user) }
    let(:tokens) { sign_in(params) }
    let(:params) { { email: user[:email], password: 'password' } }
    let(:new_name) { { name: 'new_user' } }
    let(:new_email) { { email: 'new@test.com' } }
    # sign_inしている状態を作る
    before { post "#{base_url}sign_in", params: params }

    context '正常' do
      context '名前の変更' do
        it 'ユーザーが名前を変更できること' do
          put base_url, params: new_name, headers: tokens
          expect(JSON.parse(response.body)['data']['name']).to eq(new_name[:name])
        end

        it 'HTTPステータスが200であること' do
          expect(response).to have_http_status(:ok)
        end
      end

      context 'メールアドレスの変更' do
        it 'ユーザーがメールアドレスを変更できること' do
          put base_url, params: new_email, headers: tokens
          expect(JSON.parse(response.body)['data']['email']).to eq(new_email[:email])
        end

        it 'HTTPステータスが200であること' do
          expect(response).to have_http_status(:ok)
        end
      end
    end

    context '異常' do
      context 'token情報がヘッダーに無い場合' do
        before { put base_url, params: new_name, headers: nil }

        it 'ユーザーが名前を変更できないこと' do
          expect(JSON.parse(response.body)['errors']).to eq(["User not found."])
        end

        it 'HTTPステータスが404である(ページが見つからない)こと' do
          put base_url, params: new_name, headers: nil
          expect(response).to have_http_status(:not_found)
        end
      end

      context '適切なリクエスト更新データ(new_name)がリクエストに無い場合' do
        before { put base_url, headers: tokens }

        it 'ユーザーが名前を変更できないこと' do
          expect(JSON.parse(response.body)['errors']).to eq(["Please submit proper account update data in request body."])
        end

        it 'HTTPステータスが422である(処理ができない)こと' do
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end

  describe 'Change password Function' do
    let!(:user) { create(:user) }
    let(:tokens) { sign_in(params) }
    let(:params) { { email: user[:email], password: 'password' } }
    let(:new_password) { { password: 'new_password', password_confirmation: 'new_password' } }
    # sign_inしている状態を作る
    before { post "#{base_url}sign_in", params: params }

    context '正常' do
      before { put "#{base_url}password", params: new_password, headers: tokens }

      it 'パスワードが変更できて再度ログインできること' do
        delete "#{base_url}sign_out", headers: tokens
        post "#{base_url}sign_in", params: { email: user[:email], password: new_password[:password] }
        expect(JSON.parse(response.body)['data']['email']).to eq(user[:email])
      end

      it 'HTTPステータスが200であること' do
        expect(response).to have_http_status(:ok)
      end
    end

    context '異常' do
      context 'token情報がヘッダーに無い場合' do
        before { put "#{base_url}password", params: new_password }

        it 'パスワードが変更できないこと' do
          expect(JSON.parse(response.body)['errors']).to eq(["Unauthorized"])
        end

        it 'HTTPステータスが401である(アクセス権がない)こと' do
          expect(response).to have_http_status(:unauthorized)
        end
      end

      context '適切なリクエスト更新データ(new_password)がリクエストに無い場合' do
        before { put "#{base_url}password", headers: tokens }

        it 'パスワードが変更できないこと' do
          expect(JSON.parse(response.body)['errors']).to eq(["You must fill out the fields labeled 'Password' and 'Password confirmation'."])
        end

        it 'HTTPステータスが422である(処理ができない)こと' do
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end
end
