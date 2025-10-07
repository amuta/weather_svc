require "rails_helper"

RSpec.describe "Forecasts API", type: :request do
  include CacheHelper

  it "rejects missing/blank address" do
    get "/api/forecast", params: { address: "" }
    expect(response).to have_http_status(400)
  end

  it "trims whitespace and handles long input" do
    stubbed = { current_c: 1, high_c: 2, low_c: 0, zip: "12345", cached: false, daily: [] }
    allow(ForecastService).to receive(:call).and_return(stubbed)

    get "/api/forecast", params: { address: "   Avenida Paulista  " }
    expect(response).to have_http_status(200)
    expect(JSON.parse(response.body)["zip"]).to eq("12345")
  end

  it "maps upstream errors to 502" do
    allow(ForecastService).to receive(:call).and_return({ error: "address not found" })
    get "/api/forecast", params: { address: "xxx" }
    expect(response).to have_http_status(502)
  end
end
