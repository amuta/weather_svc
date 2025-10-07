require 'rails_helper'

RSpec.describe 'Forecasts input validation', type: :request do
  it '400 on excessively long address' do
    get '/api/forecast', params: { address: 'a' * 5000 }
    expect(response).to have_http_status(400)
    expect(JSON.parse(response.body)).to eq('error' => 'address required or too long')
  end

  it '400 on invalid hourly parameter' do
    get '/api/forecast', params: { address: 'Rio', hourly: 'maybe' }
    expect(response).to have_http_status(400)
    expect(JSON.parse(response.body)).to eq('error' => 'hourly must be true|false')
  end
end
