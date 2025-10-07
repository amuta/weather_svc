class ForecastService
  def self.call(address)
    location = GeocodeService.call(address)
    return { error: "address not found" } unless location

    zip = location[:zip]
    key = "forecast:#{zip}"
    cached_before = Rails.cache.exist?(key)

    data = Rails.cache.fetch(key, expires_in: 30.minutes, race_condition_ttl: 5.minutes) do
      OpenMeteoClient.forecast(lat: location[:lat], lon: location[:lon])
    end

    data.merge(zip: zip, cached: cached_before)
  rescue => e
    { error: e.message }
  end
end
