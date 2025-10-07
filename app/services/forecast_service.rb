class ForecastService
  def self.call(address)
    location = GeocodeService.call(address)
    return { error: "address not found" } unless location

    forecast = Forecast.fetch_by_location(location)
    forecast.to_h
  rescue => e
    { error: e.message }
  end
end
