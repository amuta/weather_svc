require "rails_helper"

RSpec.describe "Forecasts API cache badge", type: :request do
  include CacheHelper

  it "returns fresh then cached on repeat" do
    with_memory_cache do
      allow(GeocodeService).to receive(:call).and_return({ lat: "1", lon: "2", zip: "99999" })
      data = { current_c: 1.1, high_c: 2.2, low_c: 0.0, daily: [], hourly: [], issued_at: "2025-10-07T12:00:00Z" }
      allow(OpenMeteoClient).to receive(:forecast).and_return(data)

      get "/api/forecast", params: { address: "x" }
      j1 = JSON.parse(response.body)
      expect(j1["cached"]).to eq(false)

      get "/api/forecast", params: { address: "x" }
      j2 = JSON.parse(response.body)
      expect(j2["cached"]).to eq(true)

      expect(OpenMeteoClient).to have_received(:forecast).once
    end
  end
end
