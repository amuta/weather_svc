module Errors
  class BadRequest < StandardError; end
  class NotFound  < StandardError; end
  class Upstream  < StandardError; end
end
