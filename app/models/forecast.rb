class Forecast
  attr_reader :zip, :current_c, :high_c, :low_c, :daily, :hourly, :issued_at, :cached

  def initialize(zip:, current_c:, high_c:, low_c:, daily:, hourly: nil, issued_at: nil, cached: false)
    @zip = zip
    @current_c = current_c
    @high_c = high_c
    @low_c = low_c
    @daily = daily
    @hourly = hourly
    @issued_at = issued_at
    @cached = cached
  end

  def to_h
    h = { zip:, current_c:, high_c:, low_c:, daily:, issued_at:, cached: }
    h[:hourly] = hourly if hourly
    h
  end
end
