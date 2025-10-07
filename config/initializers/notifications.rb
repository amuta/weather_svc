ActiveSupport::Notifications.subscribe("http.get") do |name, start, finish, _id, p|
  AppLogger.event(name,
    uri: p[:uri], status: p[:status],
    retries: p[:retries], redirects: p[:redirects],
    duration_ms: ((finish - start) * 1000).round
  )
end

ActiveSupport::Notifications.subscribe("cache.fetch") do |name, start, finish, _id, p|
  AppLogger.event(name,
    area: p[:area], key: p[:key], hit: p[:hit],
    ttl: p[:ttl], duration_ms: ((finish - start) * 1000).round
  )
end
