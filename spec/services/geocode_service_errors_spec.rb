require 'rails_helper'

RSpec.describe GeocodeService do
  it 'raises NotFound for nil result' do
    allow(NominatimClient).to receive(:lookup).and_return(nil)
    expect { GeocodeService.call('x') }.to raise_error(Errors::NotFound, 'address not found')
  end

  it 'raises NotFound for missing zip' do
    allow(NominatimClient).to receive(:lookup).and_return({ lat: '1', lon: '2', zip: nil })
    expect { GeocodeService.call('x') }.to raise_error(Errors::NotFound, 'missing zip')
  end
end
