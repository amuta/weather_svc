class Forecast
  attr_reader :zip, :current_c, :high_c, :low_c, :daily, :hourly, :issued_at, :cached
  def initialize(zip:, current_c:, high_c:, low_c:, daily:, hourly: nil, issued_at: nil, cached: false)
    @zip, @current_c, @high_c, @low_c, @daily, @hourly, @issued_at, @cached =
      [zip, current_c, high_c, low_c, daily, hourly, issued_at, cached]
  end

  def self.fetch_by_location(location, include_hourly: false)
    zip = location[:zip]
    data, cached = Cache.fetch(:forecast, zip, ttl: AppConfig.forecast_ttl_s, race_condition_ttl: AppConfig.forecast_race_ttl_s) do
      OpenMeteoClient.forecast(lat: location[:lat], lon: location[:lon])
    end
    hourly = include_hourly ? data[:hourly] : nil
    new(zip:, current_c: data[:current_c], high_c: data[:high_c], low_c: data[:low_c],
        daily: data[:daily], hourly: hourly, issued_at: data[:issued_at], cached:)
  end

  def to_h
    h = { zip:, current_c:, high_c:, low_c:, daily:, issued_at:, cached: }
    h[:hourly] = hourly if hourly
    h
  end
end
