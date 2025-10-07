require "uri"
require_relative "../http_helpers"

class OpenMeteoClient
  def self.forecast(lat:, lon:)
    uri = URI(AppConfig.openmeteo_base_url)
    uri.query = URI.encode_www_form(
      latitude: lat, longitude: lon, current_weather: true,
      daily: "temperature_2m_max,temperature_2m_min",
      hourly: "temperature_2m",
      timezone: AppConfig.openmeteo_timezone
    )

    j = HttpHelpers.get_json(uri)

    issued_at = j.dig("current_weather", "time")
    current_c = j.dig("current_weather", "temperature")

    dates = j.dig("daily", "time") || []
    highs = j.dig("daily", "temperature_2m_max") || []
    lows  = j.dig("daily", "temperature_2m_min") || []

    issued_date = issued_at&.split("T")&.first
    idx = issued_date ? dates.index(issued_date) || 0 : 0

    daily = dates.map.with_index { |d, i| { date: d, max_c: highs[i], min_c: lows[i] } }
    high_c = highs[idx]
    low_c  = lows[idx]

    h_times = j.dig("hourly", "time") || []
    h_temps = j.dig("hourly", "temperature_2m") || []
    hourly  = h_times.map.with_index { |t, i| { time: t, temp_c: h_temps[i] } }

    { current_c:, high_c:, low_c:, daily:, hourly:, issued_at: issued_at }
  end
end
