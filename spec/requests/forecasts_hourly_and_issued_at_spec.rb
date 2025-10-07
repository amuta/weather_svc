require "rails_helper"

RSpec.describe "Forecasts payload shape", type: :request do
  it "includes issued_at always and hourly only when requested" do
    allow(GeocodeService).to receive(:call).and_return({ lat: "1", lon: "2", zip: "20000-000" })

    f_without_hourly = Forecast.new(
      zip: "20000-000",
      current_c: 26.5, high_c: 29.0, low_c: 20.0,
      daily: [{ date: "2025-10-07", max_c: 29.0, min_c: 20.0 }],
      issued_at: "2025-10-07T14:23:45Z",
      hourly: nil,
      cached: false
    )

    f_with_hourly = Forecast.new(
      zip: "20000-000",
      current_c: 26.5, high_c: 29.0, low_c: 20.0,
      daily: [{ date: "2025-10-07", max_c: 29.0, min_c: 20.0 }],
      issued_at: "2025-10-07T14:23:45Z",
      hourly: [{ time: "2025-10-07T14:00", temp_c: 26.0 }],
      cached: false
    )

    allow(Forecast).to receive(:fetch_by_location).with(anything, include_hourly: false).and_return(f_without_hourly)
    allow(Forecast).to receive(:fetch_by_location).with(anything, include_hourly: true).and_return(f_with_hourly)

    get "/api/forecast", params: { address: "Rio" }
    json = JSON.parse(response.body)
    expect(json["issued_at"]).to eq("2025-10-07T14:23:45Z")
    expect(json).not_to have_key("hourly")

    get "/api/forecast", params: { address: "Rio", hourly: "true" }
    json2 = JSON.parse(response.body)
    expect(json2["hourly"]).to be_an(Array)
  end
end
