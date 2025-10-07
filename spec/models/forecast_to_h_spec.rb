require "rails_helper"

RSpec.describe Forecast do
  it "emits stable keys" do
    f = described_class.new(zip:"z", current_c:1, high_c:nil, low_c:nil, daily:[], cached:true)
    expect(f.to_h.keys).to eq(%i[zip current_c high_c low_c daily cached])
  end
end
