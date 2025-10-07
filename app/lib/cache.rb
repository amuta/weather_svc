require 'digest'

module Cache
  def self.key(area, id)
    "#{AppConfig.cache_namespace}:#{area}:#{Digest::SHA256.hexdigest(id.to_s)}"
  end

  def self.fetch(area, id, ttl:, race_condition_ttl: nil)
    ran = false
    cache_key = key(area, id)
    ActiveSupport::Notifications.instrument("cache.fetch", area:, key: cache_key, ttl:) do |payload|
      value = Rails.cache.fetch(cache_key, expires_in: ttl, race_condition_ttl:) do
        ran = true
        yield
      end
      payload[:hit] = !ran
      [value, !ran]
    end
  end

  def self.write(area, id, value, ttl:) = Rails.cache.write(key(area, id), value, expires_in: ttl)
  def self.delete(area, id) = Rails.cache.delete(key(area, id))
end
