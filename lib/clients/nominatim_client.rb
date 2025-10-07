require "net/http"
require "uri"
require "json"

class NominatimClient
  BASE_URL = "https://nominatim.openstreetmap.org/search"
  USER_AGENT = "rails-weather-assessment"

  def self.lookup(q)
    uri = URI(BASE_URL)
    uri.query = URI.encode_www_form(format: "jsonv2", addressdetails: 1, q: q)
    j = get_json(uri)
    f = j&.first
    return nil unless f
    {
      lat: f["lat"],
      lon: f["lon"],
      zip: f.dig("address", "postcode")
    }
  end

  def self.get_json(uri)
    req = Net::HTTP::Get.new(uri)
    req["User-Agent"] = USER_AGENT
    Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      res = http.request(req)
      raise "nominatim #{res.code}" unless res.is_a?(Net::HTTPSuccess)
      JSON.parse(res.body)
    end
  end
end
