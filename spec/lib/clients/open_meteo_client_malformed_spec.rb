require 'rails_helper'

RSpec.describe OpenMeteoClient do
  describe 'defensive parsing' do
    it 'handles malformed issued_at gracefully' do
      body = {
        'timezone' => 'UTC',
        'current_weather' => { 'temperature' => 25.0, 'time' => 'not-a-date' },
        'daily' => {
          'time' => %w[2025-10-07 2025-10-08],
          'temperature_2m_max' => [29.0, 31.0],
          'temperature_2m_min' => [20.0, 19.0]
        },
        'hourly' => { 'time' => [], 'temperature_2m' => [] }
      }
      allow(HttpHelpers).to receive(:get_json).and_return(body)
      r = OpenMeteoClient.forecast(lat: '0', lon: '0')
      expect(r[:high_c]).to eq(29.0)
      expect(r[:low_c]).to eq(20.0)
    end

    it 'handles malformed daily dates gracefully' do
      body = {
        'timezone' => 'UTC',
        'current_weather' => { 'temperature' => 25.0, 'time' => '2025-10-07T10:00' },
        'daily' => {
          'time' => %w[2025-10-07 invalid-date 2025-10-09],
          'temperature_2m_max' => [29.0, 31.0, 28.0],
          'temperature_2m_min' => [20.0, 19.0, 18.0]
        },
        'hourly' => { 'time' => [], 'temperature_2m' => [] }
      }
      allow(HttpHelpers).to receive(:get_json).and_return(body)
      r = OpenMeteoClient.forecast(lat: '0', lon: '0')
      expect(r[:daily].length).to eq(2)
      expect(r[:daily].map { |d| d[:date] }).to eq(%w[2025-10-07 2025-10-09])
    end

    it 'handles nil issued_at without timezone error' do
      body = {
        'timezone' => 'America/Sao_Paulo',
        'current_weather' => { 'temperature' => 25.0 },
        'daily' => {
          'time' => %w[2025-10-07 2025-10-08],
          'temperature_2m_max' => [29.0, 31.0],
          'temperature_2m_min' => [20.0, 19.0]
        },
        'hourly' => { 'time' => [], 'temperature_2m' => [] }
      }
      allow(HttpHelpers).to receive(:get_json).and_return(body)
      r = OpenMeteoClient.forecast(lat: '0', lon: '0')
      expect(r[:high_c]).to eq(29.0)
      expect(r[:low_c]).to eq(20.0)
    end

    it 'handles invalid timezone gracefully' do
      body = {
        'timezone' => 'Invalid/Timezone',
        'current_weather' => { 'temperature' => 25.0, 'time' => '2025-10-07T10:00' },
        'daily' => {
          'time' => %w[2025-10-07 2025-10-08],
          'temperature_2m_max' => [29.0, 31.0],
          'temperature_2m_min' => [20.0, 19.0]
        },
        'hourly' => { 'time' => [], 'temperature_2m' => [] }
      }
      allow(HttpHelpers).to receive(:get_json).and_return(body)
      r = OpenMeteoClient.forecast(lat: '0', lon: '0')
      expect(r[:high_c]).to eq(29.0)
      expect(r[:low_c]).to eq(20.0)
    end

    it 'handles empty string issued_at (tz.parse returns nil)' do
      body = {
        'timezone' => 'UTC',
        'current_weather' => { 'temperature' => 25.0, 'time' => '' },
        'daily' => {
          'time' => %w[2025-10-07 2025-10-08],
          'temperature_2m_max' => [29.0, 31.0],
          'temperature_2m_min' => [20.0, 19.0]
        },
        'hourly' => { 'time' => [], 'temperature_2m' => [] }
      }
      allow(HttpHelpers).to receive(:get_json).and_return(body)
      r = OpenMeteoClient.forecast(lat: '0', lon: '0')
      expect(r[:high_c]).to eq(29.0)
      expect(r[:low_c]).to eq(20.0)
    end
  end
end
