require "uri"
require_relative "../http_helpers"

class NominatimClient
  BASE_URL = "https://nominatim.openstreetmap.org/search"
  USER_AGENT = "rails-weather-assessment (contact: you@example.com)"

  def self.lookup(q)
    uri = URI(BASE_URL)
    uri.query = URI.encode_www_form(format: "jsonv2", addressdetails: 1, q:)
    j = HttpHelpers.get_json(uri, headers: { "User-Agent" => USER_AGENT })
    f = j&.first
    return nil unless f
    { lat: f["lat"], lon: f["lon"], zip: f.dig("address", "postcode") }
  end
end
