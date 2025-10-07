class ForecastsController < ApplicationController
  def show
    address = params[:address].to_s.strip
    return render json: { error: "address required" }, status: 400 if address.empty?

    want_hourly = ActiveModel::Type::Boolean.new.cast(params[:hourly])
    result = ForecastService.call(address)
    status = result[:error] ? 502 : 200

    result = result.dup
    result.delete(:hourly) unless want_hourly

    render json: result, status: status
  end
end
