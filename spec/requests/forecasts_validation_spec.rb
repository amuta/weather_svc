require "rails_helper"

RSpec.describe "Forecasts API", type: :request do
  include CacheHelper

  it "rejects missing/blank address" do
    get "/api/forecast", params: { address: "" }
    expect(response).to have_http_status(400)
  end

  it "trims whitespace and handles long input" do
    location = { lat: '1', lon: '2', zip: '12345' }
    forecast = Forecast.new(current_c: 1, high_c: 2, low_c: 0, zip: "12345", cached: false, daily: [])
    allow(GeocodeService).to receive(:call).with("Avenida Paulista").and_return(location)
    allow(Forecast).to receive(:fetch_by_location).and_return(forecast)

    get "/api/forecast", params: { address: "   Avenida Paulista  " }
    expect(response).to have_http_status(200)
    expect(JSON.parse(response.body)["zip"]).to eq("12345")
  end

  it "maps upstream errors to 502" do
    allow(GeocodeService).to receive(:call).and_raise(Errors::Upstream, "geocoder unavailable")
    get "/api/forecast", params: { address: "xxx" }
    expect(response).to have_http_status(502)
  end
end
