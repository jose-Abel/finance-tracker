class CryptosController < ApplicationController

  def search
    if params[:crypto].present?
      @crypto = Stock.look_up(params[:crypto])
      
      if @crypto
        respond_to do |format|
          format.js { render partial: 'users/result' }
        end
      else
        respond_to do |format|
          flash.now[:alert] = "Please enter a valid name to search"
          format.js { render partial: 'users/result' }
        end
      end
    else
      respond_to do |format|
        flash.now[:alert] = "The field cannot be empty, please enter a name to search"
        format.js { render partial: 'users/result' }
      end
    end
  end

  def update
    crypto = Stock.check_db(params[:name])
    @updated_price = Stock.updated_price(params[:name])
    crypto.last_price = @updated_price
    crypto.save
    
    redirect_to my_portfolio_path
  end
end