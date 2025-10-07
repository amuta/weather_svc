module CacheHelper
  def with_memory_cache
    original_cache = Rails.cache
    Rails.cache = ActiveSupport::Cache::MemoryStore.new
    Rails.cache.clear
    yield
  ensure
    Rails.cache = original_cache
  end
end

RSpec.configure do |config|
  config.include CacheHelper
end
