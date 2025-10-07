require 'rails_helper'

RSpec.describe 'Forecasts E2E', type: :request, vcr: true do
  it 'returns data for Avenida Paulista' do
    get '/api/forecast', params: { address: 'Avenida Paulista, São Paulo, Brazil' }
    expect(response).to have_http_status(200)
    j = JSON.parse(response.body)
    expect(j['zip']).to be_present
    expect(j['current_c']).to be_a(Numeric)
  end
end
