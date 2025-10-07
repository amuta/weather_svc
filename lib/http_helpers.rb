require "net/http"
require "json"

module HttpHelpers
  class HttpError < StandardError
    attr_reader :response
    def initialize(msg, response) = (@response = response; super(msg))
  end

  def self.user_agent
    ua = AppConfig.http_user_agent
    ce = AppConfig.contact_email
    ce ? "#{ua} (contact: #{ce})" : ua
  end

  def self.get(uri, headers: {}, open_timeout: AppConfig.http_open_timeout,
               read_timeout: AppConfig.http_read_timeout, retries: AppConfig.http_retries,
               redirects: AppConfig.http_redirects)
    attempt = 0
    begin
      attempt += 1
      req = Net::HTTP::Get.new(uri)
      req["User-Agent"] = user_agent
      headers.each { |k,v| req[k] = v }

      Net::HTTP.start(uri.host, uri.port,
        use_ssl: uri.scheme == "https",
        open_timeout:, read_timeout:
      ) do |http|
        res = http.request(req)
        if redirects.positive? && res.is_a?(Net::HTTPRedirection) && (loc = res["location"])
          return get(URI(loc), headers:, open_timeout:, read_timeout:, retries:, redirects: redirects - 1)
        end
        return res
      end
    rescue Timeout::Error, Errno::ECONNRESET, Errno::ETIMEDOUT, SocketError => e
      retry if attempt <= retries
      raise e
    end
  end

  def self.get_json(uri, headers: {})
    res = get(uri, headers: headers.merge("Accept" => "application/json"))
    raise HttpError.new("HTTP #{res.code}", res) unless res.is_a?(Net::HTTPSuccess)
    JSON.parse(res.body)
  end
end
