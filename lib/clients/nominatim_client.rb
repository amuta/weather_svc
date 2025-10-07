require "uri"
require_relative "../http_helpers"

class NominatimClient
  def self.lookup(q)
    uri = URI(AppConfig.nominatim_base_url)
    uri.query = URI.encode_www_form(format: "jsonv2", addressdetails: 1, limit: 1, q:)
    j = HttpHelpers.get_json(uri)
    f = j&.first
    return nil unless f
    { lat: f["lat"], lon: f["lon"], zip: f.dig("address", "postcode") }
  end
end
