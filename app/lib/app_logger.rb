module AppLogger
  SERVICE = "weather-svc"

  def self.event(event, **h)
    Rails.logger.info({ event:, service: SERVICE, **h })
  end
end
