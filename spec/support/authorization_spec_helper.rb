module AuthorizationSpecHelper
  # サインインしてアクセストークン情報を取得
  def sign_in(user)
    post "/api/auth/sign_in",
         params: { email: user[:email], password: user[:password] },
         as: :json

    response.headers.slice('client', 'access-token', 'uid')
  end
end
