require "uri"
require_relative "../http_helpers"

class OpenMeteoClient
  BASE_URL = "https://api.open-meteo.com/v1/forecast"
  USER_AGENT = "rails-weather-assessment"

  def self.forecast(lat:, lon:)
    uri = URI(BASE_URL)
    uri.query = URI.encode_www_form(
      latitude: lat, longitude: lon, current_weather: true,
      daily: "temperature_2m_max,temperature_2m_min", timezone: "auto"
    )
    j = HttpHelpers.get_json(uri, headers: { "User-Agent" => USER_AGENT })
    dates = j.dig("daily", "time") || []
    highs = j.dig("daily", "temperature_2m_max") || []
    lows  = j.dig("daily", "temperature_2m_min") || []
    daily = dates.map.with_index { |d, i| { date: d, max_c: highs[i], min_c: lows[i] } }

    {
      current_c: j.dig("current_weather", "temperature"),
      high_c: daily.first&.[](:max_c),
      low_c:  daily.first&.[](:min_c),
      daily:
    }
  end
end
