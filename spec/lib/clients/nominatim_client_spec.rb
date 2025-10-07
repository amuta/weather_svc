require 'rails_helper'

RSpec.describe NominatimClient do
  describe '.lookup' do
    it 'returns location data for a valid address', vcr: { cassette_name: 'nominatim/avenida_paulista_brazil' } do
      result = NominatimClient.lookup('Avenida Paulista, São Paulo, Brazil')

      expect(result).to be_a(Hash)
      expect(result[:lat]).to be_present
      expect(result[:lon]).to be_present
      expect(result[:zip]).to be_present
    end

    it 'returns nil for an invalid address', vcr: { cassette_name: 'nominatim/invalid_address' } do
      result = NominatimClient.lookup('XYZ Invalid Address 123456789')

      expect(result).to be_nil
    end
  end
end
