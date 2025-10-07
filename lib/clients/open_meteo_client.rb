require "net/http"
require "uri"
require "json"

class OpenMeteoClient
  BASE_URL = "https://api.open-meteo.com/v1/forecast"
  USER_AGENT = "rails-weather-assessment"

  def self.forecast(lat:, lon:)
    uri = URI(BASE_URL)
    uri.query = URI.encode_www_form(
      latitude: lat, longitude: lon, current_weather: true,
      daily: "temperature_2m_max,temperature_2m_min", timezone: "auto"
    )
    j = get_json(uri)
    dates = j.dig("daily", "time") || []
    highs = j.dig("daily", "temperature_2m_max") || []
    lows  = j.dig("daily", "temperature_2m_min") || []
    daily = dates.map.with_index { |d,i| { date: d, max_c: highs[i], min_c: lows[i] } }

    {
      current_c: j.dig("current_weather", "temperature"),
      high_c: daily.first&.[](:max_c),
      low_c:  daily.first&.[](:min_c),
      daily: daily
    }
  end

  def self.get_json(uri)
    req = Net::HTTP::Get.new(uri)
    req["User-Agent"] = USER_AGENT
    Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      res = http.request(req)
      raise "open-meteo #{res.code}" unless res.is_a?(Net::HTTPSuccess)
      JSON.parse(res.body)
    end
  end
end
