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
    end
  end
end
