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
    key = "forecast:#{zip}"

    block_ran = false
    data = Rails.cache.fetch(key, expires_in: 30.minutes, race_condition_ttl: 5.minutes) do
      block_ran = true
      OpenMeteoClient.forecast(lat: location[:lat], lon: location[:lon])
    end

    new(
      zip: zip,
      current_c: data[:current_c],
      high_c: data[:high_c],
      low_c: data[:low_c],
      daily: data[:daily],
      cached: !block_ran
    )
  end

  def to_h
    {
      zip: zip,
      current_c: current_c,
      high_c: high_c,
      low_c: low_c,
      daily: daily,
      cached: cached
    }
  end
end
