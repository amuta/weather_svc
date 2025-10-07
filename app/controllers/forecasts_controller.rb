class ForecastsController < ApplicationController
  def show
    address = params[:address].to_s.strip
    return render json: { error: "address required" }, status: 400 if address.empty?

    result = ForecastService.call(address)
    status = result[:error] ? 502 : 200
    render json: result, status: status
  end
end
