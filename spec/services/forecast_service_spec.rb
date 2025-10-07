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

    context 'when address is successfully geocoded' do
      before do
        allow(GeocodeService).to receive(:call).with('Rio de Janeiro, RJ, Brazil').and_return(location)
        allow(Forecast).to receive(:fetch_by_location).and_return(forecast)
      end

      it 'returns weather data hash' do
        result = ForecastService.call('Rio de Janeiro, RJ, Brazil')

        expect(result[:current_c]).to eq(26.5)
        expect(result[:high_c]).to eq(29.0)
        expect(result[:low_c]).to eq(20.0)
        expect(result[:zip]).to eq('20000-000')
        expect(result[:cached]).to eq(false)
        expect(result[:daily]).to be_an(Array)
      end
    end
  end
end
