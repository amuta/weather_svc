require 'rails_helper'

RSpec.describe Cache do
  it 'returns cached=false on miss then true on hit' do
    with_memory_cache do
      v1, c1 = Cache.fetch(:t, 'id', ttl: 5.minutes) { 123 }
      v2, c2 = Cache.fetch(:t, 'id', ttl: 5.minutes) { 456 }
      expect([v1, c1, v2, c2]).to eq([123, false, 123, true])
    end
  end
end
