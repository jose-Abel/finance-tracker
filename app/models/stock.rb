require 'uri'
require 'net/http'
require 'json'

class Stock < ApplicationRecord
  
  def self.look_up(ticker_symbol)  
    stocks = Stock.new
    coins_hash = stocks.listings 
    coins_hash.each do |hash|
      hash.each do |key, value|
        if ticker_symbol == key
          return value.round(2)
        end
      end
    end
  end
  
  def listings
    latest_listings_hash = get_request
    new_arr = []
    i = 0
    while i < latest_listings_hash["data"].length
      new_hash = Hash.new(0)
      new_hash[latest_listings_hash['data'][i]['name']] = latest_listings_hash['data'][i]['quote']['USD']['price']

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
