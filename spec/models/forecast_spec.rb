require 'rails_helper'

RSpec.describe Forecast do
  describe '.fetch_by_location' do
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
      allow(OpenMeteoClient).to receive(:forecast).with(lat: '-22.9068', lon: '-43.1729').and_return(weather_data)
    end

    it 'returns a Forecast instance' do
      forecast = Forecast.fetch_by_location(location)

      expect(forecast).to be_a(Forecast)
      expect(forecast.zip).to eq('20000-000')
      expect(forecast.current_c).to eq(26.5)
      expect(forecast.high_c).to eq(29.0)
      expect(forecast.low_c).to eq(20.0)
      expect(forecast.daily).to be_an(Array)
      expect(forecast.cached).to eq(false)
    end

    it 'caches forecast by zip code' do
      expect(Rails.cache).to receive(:fetch).with('forecast:20000-000', expires_in: 30.minutes, race_condition_ttl: 5.minutes)

      Forecast.fetch_by_location(location)
    end

    it 'sets cached=false on miss and cached=true on hit' do
      with_memory_cache do
        location = { lat: '-22.9068', lon: '-43.1729', zip: '99999-test' }

        first = Forecast.fetch_by_location(location)
        expect(first.cached).to eq(false)

        second = Forecast.fetch_by_location(location)
        expect(second.cached).to eq(true)
      end
    end
  end

  describe '#to_h' do
    let(:forecast) do
      Forecast.new(
        zip: '20000-000',
        current_c: 26.5,
        high_c: 29.0,
        low_c: 20.0,
        daily: [{ date: '2025-10-07', max_c: 29.0, min_c: 20.0 }],
        cached: false
      )
    end

    it 'returns a hash representation' do
      result = forecast.to_h

      expect(result).to eq({
        zip: '20000-000',
        current_c: 26.5,
        high_c: 29.0,
        low_c: 20.0,
        daily: [{ date: '2025-10-07', max_c: 29.0, min_c: 20.0 }],
        cached: false
      })
    end
  end
end
