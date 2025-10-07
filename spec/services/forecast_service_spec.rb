require 'rails_helper'

RSpec.describe ForecastService do
  describe '.call' do
    let(:location) do
      {
        lat: '37.3230',
        lon: '-122.0322',
        zip: '95014'
      }
    end

    let(:weather_data) do
      {
        current_c: 15.5,
        high_c: 20.0,
        low_c: 10.0,
        daily: [
          { date: '2025-10-07', max_c: 20.0, min_c: 10.0 }
        ]
      }
    end

    before do
      allow(Rails.cache).to receive(:exist?).and_return(false)
      allow(Rails.cache).to receive(:fetch).and_yield
    end

    context 'when address is successfully geocoded' do
      before do
        allow(GeocodeService).to receive(:call).with('Cupertino, CA').and_return(location)
        allow(OpenMeteoClient).to receive(:forecast).with(lat: '37.3230', lon: '-122.0322').and_return(weather_data)
      end

      it 'returns weather data with zip and cached flag' do
        result = ForecastService.call('Cupertino, CA')

        expect(result[:current_c]).to eq(15.5)
        expect(result[:high_c]).to eq(20.0)
        expect(result[:low_c]).to eq(10.0)
        expect(result[:zip]).to eq('95014')
        expect(result[:cached]).to eq(false)
        expect(result[:daily]).to be_an(Array)
      end

      it 'caches the forecast by zip code' do
        expect(Rails.cache).to receive(:fetch).with('forecast:95014', expires_in: 30.minutes, race_condition_ttl: 5.minutes)

        ForecastService.call('Cupertino, CA')
      end
    end

    context 'when address is not found' do
      before do
        allow(GeocodeService).to receive(:call).and_return(nil)
      end

      it 'returns error message' do
        result = ForecastService.call('Invalid Address')

        expect(result).to eq({ error: 'address not found' })
      end
    end

    context 'when forecast is already cached' do
      before do
        allow(Rails.cache).to receive(:exist?).with('forecast:95014').and_return(true)
        allow(GeocodeService).to receive(:call).and_return(location)
        allow(OpenMeteoClient).to receive(:forecast).and_return(weather_data)
      end

      it 'returns cached flag as true' do
        result = ForecastService.call('Cupertino, CA')

        expect(result[:cached]).to eq(true)
      end
    end

    context 'when an error occurs' do
      before do
        allow(GeocodeService).to receive(:call).and_raise(StandardError.new('Service error'))
      end

      it 'returns error message' do
        result = ForecastService.call('Test Address')

        expect(result).to eq({ error: 'Service error' })
      end
    end
  end
end
