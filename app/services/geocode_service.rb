class GeocodeService
  def self.call(address)
    norm = I18n.transliterate(address.to_s).strip.downcase
    data, _cached = Cache.fetch(:geocode, norm, ttl: AppConfig.geocode_ttl_s) do
      result = NominatimClient.lookup(address)
      raise Errors::NotFound, 'address not found' if result.nil?
      raise Errors::NotFound, 'missing zip' if result[:zip].to_s.empty?

      result.slice(:lat, :lon, :zip)
    end
    data
  rescue HttpHelpers::HttpError, Timeout::Error => e
    raise Errors::Upstream, e.message
  end
end
