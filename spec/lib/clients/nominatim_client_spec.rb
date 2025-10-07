require 'rails_helper'

RSpec.describe NominatimClient do
  describe '.lookup' do
    it 'returns location data for a valid address', :integration do
      result = NominatimClient.lookup('Cupertino, CA')

      expect(result).to be_a(Hash)
      expect(result[:lat]).to be_present
      expect(result[:lon]).to be_present
      expect(result[:zip]).to be_present
    end

    it 'returns nil for an invalid address', :integration do
      result = NominatimClient.lookup('XYZ Invalid Address 123456789')

      expect(result).to be_nil
    end

    it 'includes proper headers in request' do
      uri = URI('https://nominatim.openstreetmap.org/search')
      uri.query = URI.encode_www_form(format: 'jsonv2', addressdetails: 1, q: 'test')

      stub_request(:get, uri.to_s)
        .with(headers: { 'User-Agent' => 'rails-weather-assessment' })
        .to_return(status: 200, body: '[]')

      NominatimClient.lookup('test')
    end
  end
end
