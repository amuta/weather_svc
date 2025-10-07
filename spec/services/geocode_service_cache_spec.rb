require "rails_helper"

RSpec.describe GeocodeService do
  include CacheHelper

  it "normalizes address and caches" do
    with_memory_cache do
      result = { lat: "1", lon: "2", zip: "01000-000" }
      expect(NominatimClient).to receive(:lookup).once.and_return(result)

      a1 = GeocodeService.call("  AVENIDA PAULISTA  ")
      a2 = GeocodeService.call("avenida paulista")
      expect(a1).to eq(a2)
      expect(a1[:zip]).to eq("01000-000")
    end
  end
end
