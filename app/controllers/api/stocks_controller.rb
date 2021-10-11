module Api
  class StocksController < ApplicationController
    before_action :authenticate_api_user!, except: %i[index show]

    # 一応作ったがユーザーが見れるようにする意味は。。。
    def index
      stocks = Stock.all
      render json: stocks
    end

    def show
      stock = Stock.find(params[:id])
      render json: stock
    end
  end
end
