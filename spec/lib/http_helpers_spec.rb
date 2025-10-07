require "rails_helper"
require "webmock/rspec"
require "uri"
require Rails.root.join("lib/http_helpers")

RSpec.describe HttpHelpers do
  let(:url) { "https://example.org/data" }

  it "parses JSON on success" do
    stub_request(:get, url).to_return(status: 200, body: { ok: true }.to_json, headers: { "Content-Type" => "application/json" })
    json = HttpHelpers.get_json(URI(url))
    expect(json).to eq("ok" => true)
  end

  it "retries once on timeout then succeeds" do
    stub_request(:get, url)
      .to_timeout.then
      .to_return(status: 200, body: { ok: true }.to_json)

    json = HttpHelpers.get_json(URI(url))
    expect(json["ok"]).to eq(true)
  end

  it "raises HttpError on non-2xx" do
    stub_request(:get, url).to_return(status: 503, body: "oops")
    expect {
      HttpHelpers.get_json(URI(url))
    }.to raise_error(HttpHelpers::HttpError)
  end

  it "follows redirects" do
    stub_request(:get, url).to_return(status: 302, headers: { "Location" => "https://example.org/final" })
    stub_request(:get, "https://example.org/final").to_return(status: 200, body: { ok: true }.to_json)
    json = HttpHelpers.get_json(URI(url))
    expect(json["ok"]).to eq(true)
  end

  it "uses UA with optional contact" do
    stub_const("ENV", ENV.to_hash.merge("HTTP_USER_AGENT" => "ua", "CONTACT_EMAIL" => "c@e"))
    stub_request(:get, "https://example.org/data").with(headers: { "User-Agent" => "ua (contact: c@e)" })
      .to_return(status: 200, body: "{}")
    HttpHelpers.get_json(URI("https://example.org/data"))
  end

  it "stops on redirect loop" do
    stub_request(:get, url).to_return(status: 302, headers: { "Location" => url })
    expect {
      HttpHelpers.get_json(URI(url))
    }.to raise_error(HttpHelpers::HttpError)
  end

  it "raises on invalid JSON" do
    stub_request(:get, url).to_return(status: 200, body: "{")
    expect {
      HttpHelpers.get_json(URI(url))
    }.to raise_error(JSON::ParserError)
  end
end
