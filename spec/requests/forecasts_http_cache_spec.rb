require "rails_helper"

RSpec.describe "Forecasts HTTP caching", type: :request do
  include CacheHelper

  it "sets Cache-Control and X-Cache headers" do
    with_memory_cache do
      location = { lat: "1", lon: "2", zip: "Z" }
      allow(GeocodeService).to receive(:call).with("x").and_return(location)
      allow(OpenMeteoClient).to receive(:forecast).and_return({
        current_c: 1, high_c: 2, low_c: 0, daily: [], hourly: [], issued_at: "t"
      })

      get "/api/forecast", params: { address: "x" }
      expect(response.headers["Cache-Control"]).to include("public")
      expect(response.headers["Cache-Control"]).to include("max-age=1800")
      expect(response.headers["X-Cache"]).to eq("MISS")

      get "/api/forecast", params: { address: "x" }
      expect(response.headers["X-Cache"]).to eq("HIT")
    end
  end
end
