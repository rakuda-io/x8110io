module Api
  class UsersController < ApplicationController
    before_action :authenticate_api_user!, except: %i[index show]

    def index
      users = User.order(created_at: :desc)
      render json: users
    end

    def show
      user = User.find(params[:id])
      render json: user
    end

    def create; end
  end
end
