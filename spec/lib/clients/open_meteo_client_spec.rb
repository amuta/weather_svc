require 'rails_helper'

RSpec.describe OpenMeteoClient do
  describe '.forecast' do
    it 'returns weather forecast for valid coordinates', vcr: { cassette_name: 'open_meteo/rio_de_janeiro_forecast' } do
      result = OpenMeteoClient.forecast(lat: '-22.9068', lon: '-43.1729')

      expect(result).to be_a(Hash)
      expect(result[:current_c]).to be_a(Numeric)
      expect(result[:high_c]).to be_a(Numeric)
      expect(result[:low_c]).to be_a(Numeric)
      expect(result[:daily]).to be_an(Array)
      expect(result[:daily].first).to include(:date, :max_c, :min_c)
      expect(result[:hourly]).to be_an(Array)
      expect(result[:hourly].first).to include(:time, :temp_c) if result[:hourly].any?
      expect(result[:issued_at]).to be_a(String)
    end
  end

  it "picks highs/lows for API-local 'today' near midnight" do
    body = {
      "timezone"=>"America/Sao_Paulo",
      "current_weather"=>{"temperature"=>21.0, "time"=>"2025-10-07T23:55"},
      "daily"=> {
        "time"=>["2025-10-07","2025-10-08"],
        "temperature_2m_max"=>[29.0, 30.0],
        "temperature_2m_min"=>[20.0, 19.0]
      },
      "hourly"=> { "time"=>[], "temperature_2m"=>[] }
    }.to_json

    stub_request(:get, /open-meteo/).to_return(status: 200, body: body, headers: { "Content-Type"=>"application/json" })

    r = OpenMeteoClient.forecast(lat: "-23.5", lon: "-46.6")
    expect(r[:high_c]).to eq(29.0)
    expect(r[:low_c]).to eq(20.0)
  end
end
