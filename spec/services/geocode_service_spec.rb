require 'rails_helper'

RSpec.describe GeocodeService do
  describe '.call' do
    context 'when address is found' do
      let(:nominatim_result) do
        {
          lat: '37.3230',
          lon: '-122.0322',
          zip: '95014'
        }
      end

      before do
        allow(NominatimClient).to receive(:lookup).with('Cupertino, CA').and_return(nominatim_result)
      end

      it 'returns location data with lat, lon, and zip' do
        result = GeocodeService.call('Cupertino, CA')

        expect(result).to eq({
          lat: '37.3230',
          lon: '-122.0322',
          zip: '95014'
        })
      end
    end

    context 'when address is not found' do
      before do
        allow(NominatimClient).to receive(:lookup).and_return(nil)
      end

      it 'returns nil' do
        result = GeocodeService.call('Invalid Address')
        expect(result).to be_nil
      end
    end

    context 'when result has no zip' do
      before do
        allow(NominatimClient).to receive(:lookup).and_return({ lat: '1.0', lon: '2.0', zip: nil })
      end

      it 'returns nil' do
        result = GeocodeService.call('Address Without Zip')
        expect(result).to be_nil
      end
    end

    context 'when NominatimClient raises an error' do
      before do
        allow(NominatimClient).to receive(:lookup).and_raise(StandardError.new('API error'))
      end

      it 'raises an error with descriptive message' do
        expect {
          GeocodeService.call('Test Address')
        }.to raise_error('Geocoding failed: API error')
      end
    end
  end
end
