class ForecastService
  def self.call(address, include_hourly: false)
    loc = GeocodeService.call(address)

    data, cached = Cache.fetch(:forecast, loc[:zip],
                               ttl: AppConfig.forecast_ttl_s,
                               race_condition_ttl: AppConfig.forecast_race_ttl_s) do
      OpenMeteoClient.forecast(lat: loc[:lat], lon: loc[:lon])
    end

    Forecast.new(
      zip: loc[:zip],
      current_c: data[:current_c],
      high_c: data[:high_c],
      low_c: data[:low_c],
      daily: data[:daily],
      hourly: (include_hourly ? data[:hourly] : nil),
      issued_at: data[:issued_at],
      cached: cached
    )
  rescue HttpHelpers::HttpError, Timeout::Error => e
    raise Errors::Upstream, e.message
  end
end
