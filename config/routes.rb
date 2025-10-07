Rails.application.routes.draw do
  get "/api/forecast", to: "forecasts#show"
  root "forecasts#show"

  get "up" => "rails/health#show", as: :rails_health_check
end
