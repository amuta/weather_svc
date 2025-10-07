require "rails_helper"

RSpec.describe Forecast do
  it "emits stable keys" do
    f = described_class.new(zip:"z", current_c:1, high_c:nil, low_c:nil, daily:[], hourly:[], issued_at:"2025-01-01T00:00:00Z", cached:true)
    expect(f.to_h.keys).to eq(%i[zip current_c high_c low_c daily hourly issued_at cached])
  end
end
