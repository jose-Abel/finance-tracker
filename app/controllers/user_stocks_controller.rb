class UserStocksController < ApplicationController

  def create
    crypto = Stock.check_db(params[:name])
    if crypto.blank?
      crypto = Stock.look_up(params[:name])
      crypto.save
    end
    @user_stock = UserStock.create(user: current_user, stock: crypto)
    flash[:notice] = "Crypto #{crypto.name} was successfully added to your portfolio"
    redirect_to my_portfolio_path
  end

  def destroy
    crypto = Stock.find(params[:id])
    user_stock = UserStock.where(user_id: current_user.id, stock_id: crypto.id).first
    user_stock.destroy
    flash[:notice] = "#{crypto.name} was successfully removed from portfolio"
    redirect_to my_portfolio_path
  end
end
