class GeocodeService
  def self.call(address)
    result = NominatimClient.lookup(address)
    return nil unless result && result[:zip]

    {
      lat: result[:lat],
      lon: result[:lon],
      zip: result[:zip]
    }
  rescue => e
    raise "Geocoding failed: #{e.message}"
  end
end
