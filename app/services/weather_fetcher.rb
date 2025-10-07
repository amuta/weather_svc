require "json"

class WeatherFetcher
  def self.call(address)
    loc = NominatimClient.lookup(address)
    return { error: "address not found" } unless loc && loc[:zip]

    zip = loc[:zip]
    key = "forecast:#{zip}"
    cached_before = Rails.cache.exist?(key)

    data = Rails.cache.fetch(key, expires_in: 30.minutes, race_condition_ttl: 5.minutes) do
      OpenMeteoClient.forecast(lat: loc[:lat], lon: loc[:lon])
    end

    data.merge(zip: zip, cached: cached_before)
  rescue => e
    { error: e.message }
  end
end
