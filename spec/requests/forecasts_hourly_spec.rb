require 'rails_helper'

RSpec.describe 'Forecasts API hourly parameter', type: :request do
  include CacheHelper

  it 'excludes hourly data by default' do
    with_memory_cache do
      allow(GeocodeService).to receive(:call).and_return({ lat: '1', lon: '2', zip: '99999' })
      data = { current_c: 1.1, high_c: 2.2, low_c: 0.0, daily: [], hourly: [{ time: '2025-10-07T00:00', temp_c: 20.0 }],
               issued_at: '2025-10-07T12:00:00Z' }
      allow(OpenMeteoClient).to receive(:forecast).and_return(data)

      get '/api/forecast', params: { address: 'x' }
      j = JSON.parse(response.body)

      expect(j['hourly']).to be_nil
      expect(j['issued_at']).to eq('2025-10-07T12:00:00Z')
    end
  end

  it 'includes hourly data when hourly=true' do
    with_memory_cache do
      allow(GeocodeService).to receive(:call).and_return({ lat: '1', lon: '2', zip: '99999' })
      data = { current_c: 1.1, high_c: 2.2, low_c: 0.0, daily: [], hourly: [{ time: '2025-10-07T00:00', temp_c: 20.0 }],
               issued_at: '2025-10-07T12:00:00Z' }
      allow(OpenMeteoClient).to receive(:forecast).and_return(data)

      get '/api/forecast', params: { address: 'x', hourly: 'true' }
      j = JSON.parse(response.body)

      expect(j['hourly']).to be_an(Array)
      expect(j['hourly'].first['time']).to eq('2025-10-07T00:00')
      expect(j['hourly'].first['temp_c']).to eq(20.0)
    end
  end

  it 'excludes hourly data when hourly=false' do
    with_memory_cache do
      allow(GeocodeService).to receive(:call).and_return({ lat: '1', lon: '2', zip: '99999' })
      data = { current_c: 1.1, high_c: 2.2, low_c: 0.0, daily: [], hourly: [{ time: '2025-10-07T00:00', temp_c: 20.0 }],
               issued_at: '2025-10-07T12:00:00Z' }
      allow(OpenMeteoClient).to receive(:forecast).and_return(data)

      get '/api/forecast', params: { address: 'x', hourly: 'false' }
      j = JSON.parse(response.body)

      expect(j['hourly']).to be_nil
    end
  end
end
