module Api
  class HoldingsController < ApplicationController
    include FetchDividend
    before_action :authenticate_api_user!
    before_action :set_user
    before_action :wrong_user?

    def index
      holdings = @user.holdings.order(created_at: :desc)
      render json: holdings, status: :ok
    end

    def show
      holding = @user.holdings.where(id: params[:id])
      render json: holding, status: :ok
    end

    def create
      @new_holding = @user.holdings.new(holding_params)
      # quantityが未入力なら後々の計算式がエラーになるので早期リターンさせる
      if @new_holding.quantity.nil?
        render json: { errors: "You must fill out the fields of Quantity" }, status: :unprocessable_entity

      # 同じstock_idが存在するなら追加・更新
      elsif @new_holding.same_stock_id_exist?
        same_holding = @user.holdings.find_by(stock_id: @new_holding.stock_id)
        same_holding.update(quantity: same_holding.quantity += @new_holding.quantity)
        render json: same_holding, status: :ok

      # 同じstock_idが存在しないなら新規登録
      elsif @new_holding.save
        fetch_current_dividend # 現在のdividendを取得
        render status: :created, json: @new_holding

      else
        # その他の項目が未入力なら
        render json: { errors: "You must fill out the fields!!" }, status: :unprocessable_entity
      end
    end

    def update
      holding = @user.holdings.find(params[:id])
      if holding_params[:quantity]
        holding.update(
          quantity: holding.quantity += holding_params[:quantity].to_f
        )
        render status: :ok, json: holding
      else
        render json: { errors: "You must fill out the fields!!" }, status: :unprocessable_entity
      end
    end

    def destroy
      holding = @user.holdings.find(params[:id])
      render status: :ok, json: "Delete holdingID: #{params[:id]}" if holding.destroy!
    end

    private

    def holding_params
      params.permit(:quantity, :stock_id, :user_id)
    end

    def set_user
      @user = User.find(params[:user_id])
    end

    def wrong_user?
      render json: { errors: "Your access denied! No match your user id -- SignIn_UserID：#{current_api_user.id} != Request_UserID：#{params[:user_id]}" }, status: :unauthorized if current_api_user.id != params[:user_id].to_i
    end
  end
end
