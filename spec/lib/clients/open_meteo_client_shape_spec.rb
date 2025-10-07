require "rails_helper"

RSpec.describe OpenMeteoClient do
  it "handles missing daily entries gracefully" do
    allow(HttpHelpers).to receive(:get_json).and_return(
      { "current_weather"=>{"temperature"=>21.0},
        "daily"=>{"time"=>["2025-10-07"], "temperature_2m_max"=>[], "temperature_2m_min"=>[]} }
    )
    r = OpenMeteoClient.forecast(lat:"-22", lon:"-43")
    expect(r[:current_c]).to eq(21.0)
    expect(r[:high_c]).to be_nil
    expect(r[:low_c]).to be_nil
    expect(r[:daily].first).to eq({date:"2025-10-07", max_c:nil, min_c:nil})
  end
end
