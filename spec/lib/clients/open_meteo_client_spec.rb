require 'rails_helper'

RSpec.describe OpenMeteoClient do
  describe '.forecast' do
    it 'returns weather forecast for valid coordinates', :integration do
      result = OpenMeteoClient.forecast(lat: '37.3230', lon: '-122.0322')

      expect(result).to be_a(Hash)
      expect(result[:current_c]).to be_a(Numeric)
      expect(result[:high_c]).to be_a(Numeric)
      expect(result[:low_c]).to be_a(Numeric)
      expect(result[:daily]).to be_an(Array)
      expect(result[:daily].first).to include(:date, :max_c, :min_c)
    end

    it 'includes proper headers in request' do
      uri = URI('https://api.open-meteo.com/v1/forecast')
      uri.query = URI.encode_www_form(
        latitude: '37.3230',
        longitude: '-122.0322',
        current_weather: true,
        daily: 'temperature_2m_max,temperature_2m_min',
        timezone: 'auto'
      )

      stub_request(:get, uri.to_s)
        .with(headers: { 'User-Agent' => 'rails-weather-assessment' })
        .to_return(
          status: 200,
          body: {
            current_weather: { temperature: 15.5 },
            daily: {
              time: ['2025-10-07'],
              temperature_2m_max: [20.0],
              temperature_2m_min: [10.0]
            }
          }.to_json
        )

      result = OpenMeteoClient.forecast(lat: '37.3230', lon: '-122.0322')
      expect(result[:current_c]).to eq(15.5)
    end
  end
end
