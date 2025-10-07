class ApplicationController < ActionController::API
  rescue_from Errors::BadRequest, with: :handle_bad_request
  rescue_from Errors::NotFound, with: :handle_not_found
  rescue_from Errors::Upstream, HttpHelpers::HttpError, with: :handle_upstream_error

  private

  def handle_bad_request(error)
    render json: { error: error.message }, status: 400
  end

  def handle_not_found(error)
    render json: { error: error.message }, status: 404
  end

  def handle_upstream_error
    render json: { error: 'upstream error' }, status: 502
  end
end
