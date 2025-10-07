require 'rails_helper'

RSpec.describe Forecast do
  describe '#to_h' do
    let(:forecast) do
      Forecast.new(
        zip: '20000-000',
        current_c: 26.5,
        high_c: 29.0,
        low_c: 20.0,
        daily: [{ date: '2025-10-07', max_c: 29.0, min_c: 20.0 }],
        hourly: [{ time: '2025-10-07T00:00', temp_c: 22.0 }],
        issued_at: '2025-10-07T12:00:00Z',
        cached: false
      )
    end

    it 'returns a hash representation' do
      result = forecast.to_h

      expect(result).to eq({
                             zip: '20000-000',
                             current_c: 26.5,
                             high_c: 29.0,
                             low_c: 20.0,
                             daily: [{ date: '2025-10-07', max_c: 29.0, min_c: 20.0 }],
                             hourly: [{ time: '2025-10-07T00:00', temp_c: 22.0 }],
                             issued_at: '2025-10-07T12:00:00Z',
                             cached: false
                           })
    end
  end
end
