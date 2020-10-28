class User < ApplicationRecord
  has_many :user_stocks
  has_many :stocks, through: :user_stocks
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  
  def crypto_already_tracked?(name)
    crypto = Stock.check_db(name)
    return false unless crypto

    stocks.where(id: crypto.id).exists?
  end

  def under_crypto_limit?
    stocks.count < 10
  end

  def can_track_crypto?(name)
    under_crypto_limit? && !crypto_already_tracked?(name)
  end

  def full_name
    return "#{first_name} #{last_name}" if first_name || last_name
    "Anonymous"
  end
end
