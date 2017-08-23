
class Address < ApplicationRecord
  
  def self.get_google_search_url(query)
    'https://www.google.co.jp/search?q=' + URI.encode_www_form_component(query) + '&ie=UTF-8'
  end

  def self.get_google_map_route_url(srcLatitude, srcLongitude, destLatitude, destLongitude) 
    'http://maps.google.com/maps' + '?saddr=' + srcLatitude.to_s + ',' + srcLongitude.to_s + '&daddr=' + destLatitude.to_s + ',' + destLongitude.to_s + '&dirflg=w';
  end

  def self.get_distanceInKilloMeters(latitude1, longitude1, latitude2, longitude2) 
    yahoo_dis_url = 'https://map.yahooapis.jp/dist/V1/distance'
    params = {
      'coordinates' => longitude1.to_s + ',' + latitude1.to_s +  URI.encode_www_form_component(' ') + longitude2.to_s + ',' + latitude2.to_s,
      'appid' => 'dj00aiZpPUVTUEpFMHVZNng4UyZzPWNvbnN1bWVyc2VjcmV0Jng9YjA-',
      'output' => 'json'
    }
    url = yahoo_dis_url + '?' + URI.encode_www_form(params)
     
    json = open(url).read
    distance = JSON.parse(json)['Feature'][0]['Geometry']['Distance']
    distance = distance * 10
    result = distance.round(distance.to_f * 10) /10
  end
end
