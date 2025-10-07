require 'rails_helper'

RSpec.describe ForecastService do
  include CacheHelper
  include AppConfigHelper

  it 'caches by zip and marks cached flag' do
    with_memory_cache do
      allow(GeocodeService).to receive(:call).and_return({ lat: '1', lon: '2', zip: 'Z' })
      allow(OpenMeteoClient).to receive(:forecast).and_return(
        { current_c: 1.2, high_c: 3.4, low_c: 0.5, daily: [], hourly: [], issued_at: 't' }
      )

      f1 = described_class.call('addr')
      f2 = described_class.call('addr')

      expect(f1.cached).to eq(false)
      expect(f2.cached).to eq(true)
      expect(OpenMeteoClient).to have_received(:forecast).once
    end
  end

  it 'uses configured TTLs' do
    stub_forecast_ttls(main: 30.minutes, race: 5.minutes)
    allow(GeocodeService).to receive(:call).and_return({ lat: '1', lon: '2', zip: 'Z' })
    expect(Cache).to receive(:fetch).with(:forecast, 'Z',
      ttl: 30.minutes, race_condition_ttl: 5.minutes).and_call_original
    allow(OpenMeteoClient).to receive(:forecast).and_return(
      { current_c: 0, high_c: 0, low_c: 0, daily: [], hourly: [], issued_at: 't' }
    )
    described_class.call('addr')
  end
end
