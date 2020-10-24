class CryptosController < ApplicationController

  def search
    @crypto = Stock.look_up(params[:crypto])
    render 'users/my_portfolio'
  end
end