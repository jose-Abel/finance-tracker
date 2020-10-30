require 'uri'
require 'net/http'
require 'json'

class Stock < ApplicationRecord
  has_many :user_stocks
  has_many :users, through: :user_stocks

  validates :name, :ticker, presence: true

  def self.look_up(symbol)
    new_name = ''
    new_symbol = ''
    new_price = 0
    stocks = Stock.new
    coins_hash = stocks.listings

    coins_hash.each do |hash|
      hash.each do |name, price|
        if symbol == name
          new_name = name
          new_symbol = hash['symbol']
          new_price = price.round(2)
        end
      end
    end
    
    begin
      unless new_name.empty?
        new(name: new_name, last_price: new_price, ticker: new_symbol)
      end
    rescue => exception
      return nil
    end
  end

  def self.updated_price(ticker_symbol)
    new_price = 0
    stocks = Stock.new
    coins_hash = stocks.listings
  
    coins_hash.each do |hash|
      hash.each do |name, price|
        if ticker_symbol == name
          new_price = price.round(2)
        end
      end
    end
    new_price
  end

  def self.check_db(symbol)
    where(name: symbol).first
  end
  
  def listings
    latest_listings_hash = get_request
    new_arr = []
    i = 0
    while i < latest_listings_hash["data"].length
      new_hash = Hash.new(0)

      new_hash[latest_listings_hash['data'][i]['name']] = latest_listings_hash['data'][i]['quote']['USD']['price']

      new_hash["symbol"] = latest_listings_hash['data'][i]['symbol']

      new_arr << new_hash
      i += 1
    end
    new_arr
  end

  def get_request
    url = 'https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest?'
    uri = URI(url)
    http = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https')
    request = Net::HTTP::Get.new(uri)
    request['Content-Type'] = 'application/json'
    request['X-CMC_PRO_API_KEY'] = Rails.application.credentials.coinmarketcap_client[:coinmarketcap_api_key]

    response = http.request(request)
    result = response.read_body
    my_hash = JSON.parse(result)
    my_hash
  end
end
