require 'rails_helper'

RSpec.describe OpenMeteoClient do
  it "extracts issued_at and selects today's high/low by issued date" do
    fake = {
      'current_weather' => { 'temperature' => 23.4, 'time' => '2025-10-07T10:00' },
      'daily' => {
        'time' => %w[2025-10-06 2025-10-07 2025-10-08],
        'temperature_2m_max' => [30.0, 31.5, 29.0],
        'temperature_2m_min' => [18.0, 19.2, 17.5]
      },
      'hourly' => {
        'time' => ['2025-10-07T09:00', '2025-10-07T10:00'],
        'temperature_2m' => [22.2, 23.4]
      }
    }
    allow(HttpHelpers).to receive(:get_json).and_return(fake)

    res = OpenMeteoClient.forecast(lat: '-22.9', lon: '-43.1')

    expect(res[:issued_at]).to eq('2025-10-07T10:00')
    expect(res[:current_c]).to eq(23.4)
    expect(res[:high_c]).to eq(31.5)
    expect(res[:low_c]).to eq(19.2)
    expect(res[:hourly]).to eq([{ time: '2025-10-07T09:00', temp_c: 22.2 },
                                { time: '2025-10-07T10:00', temp_c: 23.4 }])
  end
end
