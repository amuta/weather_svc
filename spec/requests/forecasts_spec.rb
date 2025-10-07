require 'rails_helper'

RSpec.describe 'Forecasts API', type: :request do
  describe 'GET /api/forecast' do
    context 'when address is missing' do
      it 'returns 400 with error message' do
        get '/api/forecast', params: { address: '' }
        expect(response).to have_http_status(400)
        expect(JSON.parse(response.body)).to eq({ 'error' => 'address required' })
      end

      it 'returns 400 when address is blank' do
        get '/api/forecast', params: { address: '   ' }
        expect(response).to have_http_status(400)
        expect(JSON.parse(response.body)).to eq({ 'error' => 'address required' })
      end
    end

    context 'when address is provided' do
      let(:weather_result) do
        {
          current_c: 15.5,
          high_c: 20.0,
          low_c: 10.0,
          zip: '94014',
          cached: false,
          daily: [
            { date: '2025-10-07', max_c: 20.0, min_c: 10.0 }
          ]
        }
      end

      before do
        allow(ForecastService).to receive(:call).with('Cupertino, CA').and_return(weather_result)
      end

      it 'returns 200 with weather data' do
        get '/api/forecast', params: { address: 'Cupertino, CA' }
        expect(response).to have_http_status(200)
        json = JSON.parse(response.body, symbolize_names: true)
        expect(json[:current_c]).to eq(15.5)
        expect(json[:zip]).to eq('94014')
      end
    end

    context 'when ForecastService returns an error' do
      before do
        allow(ForecastService).to receive(:call).and_return({ error: 'address not found' })
      end

      it 'returns 502 with error message' do
        get '/api/forecast', params: { address: 'Invalid Address' }
        expect(response).to have_http_status(502)
        expect(JSON.parse(response.body)).to eq({ 'error' => 'address not found' })
      end
    end
  end
end
