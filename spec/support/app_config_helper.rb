module AppConfigHelper
  def stub_forecast_ttls(main:, race:)
    allow(AppConfig).to receive(:forecast_ttl_s).and_return(main)
    allow(AppConfig).to receive(:forecast_race_ttl_s).and_return(race)
  end
end
