require "digest"

module Cache
  KEY_NS = "wx:v1"

  def self.key(area, id)
    "#{KEY_NS}:#{area}:#{Digest::SHA256.hexdigest(id.to_s)}"
  end

  def self.fetch(area, id, ttl:, race_condition_ttl: nil)
    ran_block = false
    value = Rails.cache.fetch(
      key(area, id),
      expires_in: ttl,
      race_condition_ttl: race_condition_ttl
    ) do
      ran_block = true
      yield
    end
    [value, !ran_block]
  end

  def self.write(area, id, value, ttl:)
    Rails.cache.write(key(area, id), value, expires_in: ttl)
  end

  def self.delete(area, id)
    Rails.cache.delete(key(area, id))
  end
end
