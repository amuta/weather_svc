class ForecastService
  def self.call(address, include_hourly: false)
    location = GeocodeService.call(address)
    forecast = Forecast.fetch_by_location(location, include_hourly: include_hourly)
    forecast.to_h
  rescue HttpHelpers::HttpError, Timeout::Error => e
    raise Errors::Upstream, e.message
  end
end
