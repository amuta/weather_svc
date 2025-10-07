module AppConfig
  module_function

  def int(name, default) = Integer(ENV.fetch(name, default))
  def float(name, default) = Float(ENV.fetch(name, default))
  def str(name, default = nil) = ENV.key?(name) ? ENV[name] : default

  def bool(name, default = false)
    v = ENV.fetch(name, default ? '1' : '0').to_s.downcase
    %w[1 true yes on].include?(v)
  end

  def http_open_timeout   = int('HTTP_OPEN_TIMEOUT', 3)
  def http_read_timeout   = int('HTTP_READ_TIMEOUT', 5)
  def http_retries        = int('HTTP_RETRIES', 1)
  def http_redirects      = int('HTTP_REDIRECTS', 2)
  def http_user_agent     = str('HTTP_USER_AGENT', 'rails-weather-assessment')
  def contact_email       = str('CONTACT_EMAIL', nil)

  def cache_namespace     = str('CACHE_NAMESPACE', 'wx:v1')
  def geocode_ttl_s       = int('GEOCODE_TTL_SECONDS', 12 * 60 * 60)
  def forecast_ttl_s      = int('FORECAST_TTL_SECONDS', 30 * 60)
  def forecast_race_ttl_s = int('FORECAST_RACE_TTL_SECONDS', 5 * 60)

  def nominatim_base_url  = str('NOMINATIM_BASE_URL', 'https://nominatim.openstreetmap.org/search')
  def openmeteo_base_url  = str('OPENMETEO_BASE_URL', 'https://api.open-meteo.com/v1/forecast')
  def openmeteo_timezone  = str('OPENMETEO_TIMEZONE', 'auto')
end
