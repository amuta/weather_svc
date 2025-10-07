require 'rails_helper'

RSpec.describe 'Forecasts API', type: :request do
  describe 'GET /api/forecast' do
    context 'when address is missing' do
      it 'returns 400 with error message' do
        get '/api/forecast', params: { address: '' }
        expect(response).to have_http_status(400)
        expect(JSON.parse(response.body)).to eq({ 'error' => 'address required or too long' })
      end

      it 'returns 400 when address is blank' do
        get '/api/forecast', params: { address: '   ' }
        expect(response).to have_http_status(400)
        expect(JSON.parse(response.body)).to eq({ 'error' => 'address required or too long' })
      end
    end

    context 'when address is provided' do
      let(:location) do
        { lat: '-22.9068', lon: '-43.1729', zip: '20000-000' }
      end

      let(:forecast) do
        Forecast.new(
          zip: '20000-000',
          current_c: 26.5,
          high_c: 29.0,
          low_c: 20.0,
          daily: [{ date: '2025-10-07', max_c: 29.0, min_c: 20.0 }],
          issued_at: '2025-10-07T12:00:00Z',
          cached: false
        )
      end

      before do
        allow(GeocodeService).to receive(:call).with('Rio de Janeiro, RJ, Brazil').and_return(location)
        allow(Forecast).to receive(:fetch_by_location).and_return(forecast)
      end

      it 'returns 200 with weather data' do
        get '/api/forecast', params: { address: 'Rio de Janeiro, RJ, Brazil' }
        expect(response).to have_http_status(200)
        json = JSON.parse(response.body, symbolize_names: true)
        expect(json[:current_c]).to eq(26.5)
        expect(json[:zip]).to eq('20000-000')
      end
    end

    context 'when ForecastService returns an error' do
      before do
        allow(GeocodeService).to receive(:call).and_raise(Errors::Upstream, 'geocoder unavailable')
      end

      it 'returns 502 with error message' do
        get '/api/forecast', params: { address: 'Invalid Address' }
        expect(response).to have_http_status(502)
        expect(JSON.parse(response.body)).to eq({ 'error' => 'geocoder unavailable' })
      end
    end
  end
end
