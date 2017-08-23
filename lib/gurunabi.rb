require 'openssl' if Rails.env.development?
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE  if Rails.env.development?
class Gurunabi  
  END_POINT = "https://api.gnavi.co.jp/"
  #, "35.531479", "139.68242"
  def search_by_latitude_longitude(latitude,longitude)
    conn = Faraday.new(:url => Gurunabi::END_POINT) do |builder|
      builder.request  :url_encoded
      builder.response :logger
      builder.adapter  :net_http
    end
    response = conn.get do |req|  # GET http://example.com/api/nyan.json?color=white&size=big
      req.url 'RestSearchAPI/20150630/', {:keyid => '2e31b47454b85ff5533e43e9bb5c3240'}
      req.params[:address] = ''
      req.params[:lunch] = '1'
      req.params[:latitude] = latitude
      req.params[:longitude] = longitude
      req.params[:format] = :json
    end
    pp JSON.parse(response.body)
  end

  def default_search(address)
    conn = Faraday.new(:url => Gurunabi::END_POINT) do |builder|
      builder.request  :url_encoded
      builder.response :logger
      builder.adapter  :net_http
    end
    response = conn.get do |req|  # GET http://example.com/api/nyan.json?color=white&size=big
      req.url 'RestSearchAPI/20150630/', {:keyid => '2e31b47454b85ff5533e43e9bb5c3240'}
      req.params[:address] = address
      req.params[:lunch] = '1'
      req.params[:format] = :json
    end
    pp JSON.parse(response.body)
  end
end


