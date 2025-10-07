class GeocodeService
  def self.call(address)
    norm = address.to_s.strip.downcase
    data, _cached = Cache.fetch(:geocode, norm, ttl: AppConfig.geocode_ttl_s) do
      result = NominatimClient.lookup(address)
      return nil if result.nil? || result[:zip].to_s.empty?
      result.slice(:lat, :lon, :zip)
    end
    data
  end
end
