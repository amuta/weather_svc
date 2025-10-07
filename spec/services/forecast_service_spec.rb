require 'rails_helper'

RSpec.describe ForecastService do
  describe '.call' do
    let(:location) do
      {
        lat: '-22.9068',
        lon: '-43.1729',
        zip: '20000-000'
      }
    end

    let(:weather_data) do
      {
        current_c: 26.5,
        high_c: 29.0,
        low_c: 20.0,
        daily: [
          { date: '2025-10-07', max_c: 29.0, min_c: 20.0 }
        ]
      }
    end

    before do
      allow(Rails.cache).to receive(:exist?).and_return(false)
      allow(Rails.cache).to receive(:fetch).and_yield
    end

    context 'when address is successfully geocoded' do
      before do
        allow(GeocodeService).to receive(:call).with('Rio de Janeiro, RJ, Brazil').and_return(location)
        allow(OpenMeteoClient).to receive(:forecast).with(lat: '-22.9068', lon: '-43.1729').and_return(weather_data)
      end

      it 'returns weather data with zip and cached flag' do
        result = ForecastService.call('Rio de Janeiro, RJ, Brazil')

        expect(result[:current_c]).to eq(26.5)
        expect(result[:high_c]).to eq(29.0)
        expect(result[:low_c]).to eq(20.0)
        expect(result[:zip]).to eq('20000-000')
        expect(result[:cached]).to eq(false)
        expect(result[:daily]).to be_an(Array)
      end

      it 'caches the forecast by zip code' do
        expect(Rails.cache).to receive(:fetch).with('forecast:20000-000', expires_in: 30.minutes, race_condition_ttl: 5.minutes)

        ForecastService.call('Rio de Janeiro, RJ, Brazil')
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
        allow(Rails.cache).to receive(:exist?).with('forecast:20000-000').and_return(true)
        allow(GeocodeService).to receive(:call).and_return(location)
        allow(OpenMeteoClient).to receive(:forecast).and_return(weather_data)
      end

      it 'returns cached flag as true' do
        result = ForecastService.call('Rio de Janeiro, RJ, Brazil')

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
