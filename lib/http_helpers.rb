require "net/http"
require "json"

module HttpHelpers
  DEFAULT_OPEN_TIMEOUT = Integer(ENV.fetch("HTTP_OPEN_TIMEOUT", 3))
  DEFAULT_READ_TIMEOUT = Integer(ENV.fetch("HTTP_READ_TIMEOUT", 5))
  DEFAULT_RETRIES      = Integer(ENV.fetch("HTTP_RETRIES", 1))
  DEFAULT_REDIRECTS    = Integer(ENV.fetch("HTTP_REDIRECTS", 2))

  class HttpError < StandardError
    attr_reader :response
    def initialize(msg, response) = (@response = response; super(msg))
  end

  def self.get(uri, headers: {}, open_timeout: DEFAULT_OPEN_TIMEOUT,
               read_timeout: DEFAULT_READ_TIMEOUT, retries: DEFAULT_RETRIES,
               redirects: DEFAULT_REDIRECTS)
    attempt = 0
    begin
      attempt += 1
      req = Net::HTTP::Get.new(uri)
      headers.each { |k, v| req[k] = v }

      Net::HTTP.start(uri.host, uri.port,
                      use_ssl: uri.scheme == "https",
                      open_timeout: open_timeout,
                      read_timeout: read_timeout) do |http|
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
