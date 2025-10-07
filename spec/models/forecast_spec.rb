require 'rails_helper'

RSpec.describe Forecast do
  include AppConfigHelper
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
        ],
        hourly: [
          { time: '2025-10-07T00:00', temp_c: 22.0 }
        ],
        issued_at: '2025-10-07T12:00:00Z'
      }
    end

    before do
      allow(OpenMeteoClient).to receive(:forecast).with(lat: '-22.9068', lon: '-43.1729').and_return(weather_data)
    end

    it 'returns a Forecast instance' do
      forecast = Forecast.fetch_by_location(location, include_hourly: true)

      expect(forecast).to be_a(Forecast)
      expect(forecast.zip).to eq('20000-000')
      expect(forecast.current_c).to eq(26.5)
      expect(forecast.high_c).to eq(29.0)
      expect(forecast.low_c).to eq(20.0)
      expect(forecast.daily).to be_an(Array)
      expect(forecast.hourly).to be_an(Array)
      expect(forecast.issued_at).to eq('2025-10-07T12:00:00Z')
      expect(forecast.cached).to eq(false)
    end

    it 'caches forecast by zip code' do
      stub_forecast_ttls(main: 30.minutes, race: 5.minutes)
      expect(Cache).to receive(:fetch).with(:forecast, '20000-000', ttl: 30.minutes, race_condition_ttl: 5.minutes).and_call_original

      Forecast.fetch_by_location(location)
    end

    it 'sets cached=false on miss and cached=true on hit' do
      with_memory_cache do
        allow(OpenMeteoClient).to receive(:forecast).and_return(
          { current_c: 1.2, high_c: 3.4, low_c: 0.5, daily: [], hourly: [], issued_at: '2025-10-07T12:00:00Z' }
        )

        first  = Forecast.fetch_by_location({ lat: '-22', lon: '-43', zip: '99999-test' })
        second = Forecast.fetch_by_location({ lat: '-22', lon: '-43', zip: '99999-test' })

        expect(first.cached).to eq(false)
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
        hourly: [{ time: '2025-10-07T00:00', temp_c: 22.0 }],
        issued_at: '2025-10-07T12:00:00Z',
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
        hourly: [{ time: '2025-10-07T00:00', temp_c: 22.0 }],
        issued_at: '2025-10-07T12:00:00Z',
        cached: false
      })
    end
  end
end
