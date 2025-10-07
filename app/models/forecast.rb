class Forecast
  attr_reader :zip, :current_c, :high_c, :low_c, :daily, :cached

  def initialize(zip:, current_c:, high_c:, low_c:, daily:, cached: false)
    @zip = zip
    @current_c = current_c
    @high_c = high_c
    @low_c = low_c
    @daily = daily
    @cached = cached
  end

  def self.fetch_by_location(location)
    zip = location[:zip]
    data, cached = Cache.fetch(:forecast, zip, ttl: AppConfig.forecast_ttl_s, race_condition_ttl: AppConfig.forecast_race_ttl_s) do
      OpenMeteoClient.forecast(lat: location[:lat], lon: location[:lon])
    end
    new(zip:, current_c: data[:current_c], high_c: data[:high_c], low_c: data[:low_c], daily: data[:daily], cached:)
  end

  def to_h = { zip:, current_c:, high_c:, low_c:, daily:, cached: }
end
