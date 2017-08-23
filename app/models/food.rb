require 'open-uri'
class Food < ApplicationRecord

  def self.rests_list(data,latitude,longitude)
    outer = []
    data = data.shuffle!
    data = data.take(5)
    data.map do |item|
      map = {}
      iterate(item,map)
      map["distance"] = Address.get_distanceInKilloMeters(latitude,longitude,map["latitude"],map["longitude"])
      map["google_search"] = Address.get_google_search_url(map["name"])
      map["how_to_go"] = Address.get_google_map_route_url(latitude,longitude,map["latitude"],map["longitude"])
      outer.push(map)
    end
    outer
  end

  def self.budget_search(rests,budget)
    outer = []
    budget ||= 1000
    rests.map do |item|
      map = {}
      iterate(item,map)
      map["google_search"] = Address.get_google_search_url(map["name"])
      outer.push(map)
    end
    outer.select {|k| k["lunch"].to_i <= budget.to_i}
    outer = outer.shuffle!
    outer = outer.take(7)
    outer
  end

  def self.iterate(h, map)
    h.each do |k,v|
      if v.is_a?(Hash)
        iterate(v,map)
      else
        v = v.join(",") if ["category_name_l"].include?(k)
        map[k] = v  if ["id","name","address","latitude","longitude","url_mobile","lunch","opentime","category_name_l"].include?(k)
      end
    end
  end
end


