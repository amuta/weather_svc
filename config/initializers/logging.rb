require "json"

class JsonFormatter < Logger::Formatter
  def call(severity, time, progname, msg)
    payload = msg.is_a?(Hash) ? msg.dup : { message: msg.to_s }
    payload[:severity] = severity
    payload[:ts] = time.utc.iso8601(3)
    payload[:progname] = progname if progname
    JSON.generate(payload) + "\n"
  end
end

Rails.application.configure do
  config.log_formatter = JsonFormatter.new
  config.log_tags = [:request_id]
end
