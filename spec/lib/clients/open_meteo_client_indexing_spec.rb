require 'rails_helper'

RSpec.describe OpenMeteoClient do
  it "uses today's highs/lows when date exists" do
    body = {
      'timezone' => 'America/Sao_Paulo',
      'current_weather' => { 'temperature' => 25.0, 'time' => '2025-10-07T23:55' },
      'daily' => {
        'time' => %w[2025-10-07 2025-10-08],
        'temperature_2m_max' => [29.0, 31.0],
        'temperature_2m_min' => [20.0, 19.0]
      },
      'hourly' => { 'time' => [], 'temperature_2m' => [] }
    }.to_json
    stub_request(:get, /open-meteo/).to_return(status: 200, body: body,
                                               headers: { 'Content-Type' => 'application/json' })
    r = described_class.forecast(lat: '0', lon: '0')
    expect(r[:high_c]).to eq(29.0)
    expect(r[:low_c]).to  eq(20.0)
  end

  it 'chooses first daily if issued_date precedes range' do
    body = {
      'timezone' => 'UTC',
      'current_weather' => { 'temperature' => 25.0, 'time' => '2025-10-05T10:00' },
      'daily' => {
        'time' => %w[2025-10-06 2025-10-07],
        'temperature_2m_max' => [28.0, 30.0],
        'temperature_2m_min' => [18.0, 19.0]
      },
      'hourly' => { 'time' => [], 'temperature_2m' => [] }
    }.to_json
    stub_request(:get, /open-meteo/).to_return(status: 200, body: body,
                                               headers: { 'Content-Type' => 'application/json' })
    r = described_class.forecast(lat: '0', lon: '0')
    expect(r[:high_c]).to eq(28.0)
    expect(r[:low_c]).to  eq(18.0)
  end

  it 'chooses last daily if issued_date exceeds range' do
    body = {
      'timezone' => 'UTC',
      'current_weather' => { 'temperature' => 25.0, 'time' => '2025-10-10T01:00' },
      'daily' => {
        'time' => %w[2025-10-07 2025-10-08 2025-10-09],
        'temperature_2m_max' => [27.0, 28.0, 29.0],
        'temperature_2m_min' => [17.0, 18.0, 19.0]
      },
      'hourly' => { 'time' => [], 'temperature_2m' => [] }
    }.to_json
    stub_request(:get, /open-meteo/).to_return(status: 200, body: body,
                                               headers: { 'Content-Type' => 'application/json' })
    r = described_class.forecast(lat: '0', lon: '0')
    expect(r[:high_c]).to eq(29.0)
    expect(r[:low_c]).to  eq(19.0)
  end

  it 'defaults to first daily when issued_at is nil' do
    body = {
      'timezone' => 'UTC',
      'daily' => {
        'time' => %w[2025-10-07 2025-10-08],
        'temperature_2m_max' => [27.0, 28.0],
        'temperature_2m_min' => [17.0, 18.0]
      },
      'hourly' => { 'time' => [], 'temperature_2m' => [] }
    }.to_json
    stub_request(:get, /open-meteo/).to_return(status: 200, body: body,
                                               headers: { 'Content-Type' => 'application/json' })
    r = described_class.forecast(lat: '0', lon: '0')
    expect(r[:high_c]).to eq(27.0)
    expect(r[:low_c]).to  eq(17.0)
  end
end
