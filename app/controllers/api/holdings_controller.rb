module Api
  class HoldingsController < ApplicationController
    before_action :authenticate_api_user!
    before_action :set_user
    before_action :correct_user?

    def index
      holdings = @user.holdings.order(created_at: :desc)

      render status: :ok, json: holdings
    end

    def show
      holding = @user.holdings.where(id: params[:id])

      render status: :ok, json: holding
    end

    def create
      new_holding = @user.holdings.new(holding_params)

      # 同じstock_idが存在するなら追加・更新
      if new_holding.same_stock_id_exist?
        same_holding = @user.holdings.find_by(stock_id: new_holding.stock_id)
        same_holding.update(quantity: same_holding.quantity += new_holding.quantity)

        # この処理をupdate時にするかは要検討
        same_holding.fetch_current_dividend

        render status: :ok, json: same_holding

      # 同じstock_idが存在しないなら新規登録
      elsif new_holding.save
        new_holding.fetch_current_dividend

        render status: :ok, json: new_holding
      else
        render status: :unprocessable_entity, json: "You must fill out the fields!!"
      end
    end

    def update
      holding = @user.holdings.find(params[:id])
      if holding_params[:quantity]
        holding.update(
          quantity: holding.quantity += holding_params[:quantity].to_f
        )
        holding.fetch_current_dividend

        render status: :ok, json: holding
      else
        render status: :unprocessable_entity, json: "You must fill out the fields!!"
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

    def correct_user?
      render json: { errors: "Access denied! No match your user id -- SignIn_UserID：#{current_api_user.id} != Request_UserID：#{params[:user_id]}" }, status: :unauthorized if current_api_user.id != params[:user_id].to_i
    end
  end
end
