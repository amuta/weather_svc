require 'uri'
require 'date'
require 'active_support'
require 'active_support/time'
require_relative '../http_helpers'

class OpenMeteoClient
  def self.forecast(lat:, lon:)
    uri = URI(AppConfig.openmeteo_base_url)
    uri.query = URI.encode_www_form(
      latitude: lat, longitude: lon, current_weather: true,
      daily: 'temperature_2m_max,temperature_2m_min',
      hourly: 'temperature_2m',
      timezone: AppConfig.openmeteo_timezone
    )

    j = HttpHelpers.get_json(uri)

    tzname    = j['timezone'] || 'UTC'
    tz        = ActiveSupport::TimeZone[tzname] || ActiveSupport::TimeZone['UTC']
    issued_at = j.dig('current_weather', 'time')

    issued_date =
      begin
        issued_at ? tz.parse(issued_at)&.to_date : nil
      rescue ArgumentError, TypeError
        nil
      end

    dates_s = j.dig('daily', 'time') || []
    highs   = j.dig('daily', 'temperature_2m_max') || []
    lows    = j.dig('daily', 'temperature_2m_min') || []

    dates = dates_s.map do |s|
      Date.iso8601(s)
    rescue StandardError
      nil
    end.compact
    idx = pick_daily_index(dates, issued_date)

    daily = dates.each_with_index.map { |d, i| { date: d.iso8601, max_c: highs[i], min_c: lows[i] } }
    high_c = idx && highs[idx]
    low_c  = idx && lows[idx]

    h_times = j.dig('hourly', 'time') || []
    h_temps = j.dig('hourly', 'temperature_2m') || []
    hourly  = h_times.map.with_index { |t, i| { time: t, temp_c: h_temps[i] } }

    current_c = j.dig('current_weather', 'temperature')
    { current_c:, high_c:, low_c:, daily:, hourly:, issued_at: issued_at }
  end

  def self.pick_daily_index(dates, issued_date)
    return 0 if dates.empty?
    return 0 unless issued_date

    exact = dates.index(issued_date)
    return exact if exact

    return 0 if issued_date < dates.first
    return dates.length - 1 if issued_date > dates.last

    dates.index { |d| d >= issued_date } || (dates.length - 1)
  end
  private_class_method :pick_daily_index
end
