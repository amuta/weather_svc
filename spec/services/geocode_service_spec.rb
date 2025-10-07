require 'rails_helper'

RSpec.describe GeocodeService do
  describe '.call' do
    context 'when address is found' do
      let(:nominatim_result) do
        {
          lat: '-22.9068',
          lon: '-43.1729',
          zip: '20000-000'
        }
      end

      before do
        allow(NominatimClient).to receive(:lookup).with('Rio de Janeiro, RJ, Brazil').and_return(nominatim_result)
      end

      it 'returns location data with lat, lon, and zip' do
        result = GeocodeService.call('Rio de Janeiro, RJ, Brazil')

        expect(result).to eq({
                               lat: '-22.9068',
                               lon: '-43.1729',
                               zip: '20000-000'
                             })
      end
    end

    context 'when address is not found' do
      before do
        allow(NominatimClient).to receive(:lookup).and_return(nil)
      end

      it 'raises NotFound error' do
        expect { GeocodeService.call('Invalid Address') }.to raise_error(Errors::NotFound, 'address not found')
      end
    end

    context 'when result has no zip' do
      before do
        allow(NominatimClient).to receive(:lookup).and_return({ lat: '1.0', lon: '2.0', zip: nil })
      end

      it 'raises NotFound error' do
        expect { GeocodeService.call('Address Without Zip') }.to raise_error(Errors::NotFound, 'missing zip')
      end
    end

    context 'when addresses have accents' do
      include CacheHelper

      it 'caches accent-insensitive addresses' do
        with_memory_cache do
          r = { lat: '1', lon: '2', zip: '01000-000' }
          expect(NominatimClient).to receive(:lookup).once.and_return(r)
          a1 = GeocodeService.call('Sao Paulo')
          a2 = GeocodeService.call('São Paulo')
          expect(a1).to eq(a2)
        end
      end
    end

    context 'when HTTP errors occur' do
      it 'raises Upstream error for HttpHelpers::HttpError' do
        response = double('response')
        http_error = HttpHelpers::HttpError.new('HTTP 503', response)
        allow(NominatimClient).to receive(:lookup).and_raise(http_error)
        expect { GeocodeService.call('Test') }.to raise_error(Errors::Upstream, 'HTTP 503')
      end

      it 'raises Upstream error for Timeout::Error' do
        allow(NominatimClient).to receive(:lookup).and_raise(Timeout::Error, 'Timeout')
        expect { GeocodeService.call('Test') }.to raise_error(Errors::Upstream)
      end
    end
  end
end
