class GeocodeService
  CACHE_TTL = 12.hours

  def self.call(address)
    norm = address.to_s.strip.downcase
    data, _cached = Cache.fetch(:geocode, norm, ttl: CACHE_TTL) do
      result = NominatimClient.lookup(address)
      raise "address not found" if result.nil?
      raise "missing zip" if result[:zip].to_s.empty?
      result.slice(:lat, :lon, :zip)
    end
    data
  rescue => e
    raise "Geocoding failed: #{e.message}"
  end
end
