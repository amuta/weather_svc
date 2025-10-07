class ForecastsController < ApplicationController
  before_action :validate_query!, only: :show

  def show
    include_hourly = params[:hourly].to_s == 'true'
    forecast = ForecastService.call(@address, include_hourly: include_hourly)
    payload  = forecast.to_h

    response.headers['Cache-Control'] = "public, max-age=#{AppConfig.forecast_ttl_s}"
    response.headers['X-Cache'] = payload[:cached] ? 'HIT' : 'MISS'
    render json: payload, status: 200
  end

  private

  def validate_query!
    addr = params[:address].to_s.strip
    raise Errors::BadRequest, 'address required or too long' if addr.empty? || addr.length > 512

    if params.key?(:hourly) && !%w[true false].include?(params[:hourly].to_s)
      raise Errors::BadRequest, 'hourly must be true|false'
    end

    @address = addr
  end
end
