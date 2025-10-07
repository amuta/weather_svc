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

    dates = j.dig("daily", "time") || []
    highs = j.dig("daily", "temperature_2m_max") || []
    lows  = j.dig("daily", "temperature_2m_min") || []
    daily = dates.map.with_index { |d,i| { date: d, max_c: highs[i], min_c: lows[i] } }

    hours = j.dig("hourly", "time") || []
    temps = j.dig("hourly", "temperature_2m") || []
    hourly = hours.map.with_index { |t,i| { time: t, temp_c: temps[i] } }

    today_s = Date.current.iso8601
    today_idx = dates.index(today_s) || 0

    {
      current_c: j.dig("current_weather", "temperature"),
      high_c: daily[today_idx]&.[](:max_c),
      low_c: daily[today_idx]&.[](:min_c),
      daily:,
      hourly:,
      issued_at: Time.now.utc.iso8601
    }
  end
end
