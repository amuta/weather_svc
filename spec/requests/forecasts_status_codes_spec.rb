require 'rails_helper'

RSpec.describe 'Forecasts status mapping', type: :request do
  it '400 when address is missing' do
    get '/api/forecast', params: { address: '' }
    expect(response).to have_http_status(400)
    expect(JSON.parse(response.body)).to eq('error' => 'address required or too long')
  end

  it '404 when address not found' do
    allow(GeocodeService).to receive(:call).and_raise(Errors::NotFound, 'address not found')
    get '/api/forecast', params: { address: 'Nope' }
    expect(response).to have_http_status(404)
    expect(JSON.parse(response.body)).to eq('error' => 'address not found')
  end

  it '502 on upstream failure' do
    allow(GeocodeService).to receive(:call).and_raise(Errors::Upstream, 'geocoder unavailable')
    get '/api/forecast', params: { address: 'X' }
    expect(response).to have_http_status(502)
    expect(JSON.parse(response.body)).to eq('error' => 'upstream error')
  end
end
