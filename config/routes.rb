Rails.application.routes.draw do
  scope :api do
    get 'forecast', to: 'forecasts#show'
  end

  get 'up' => 'rails/health#show', as: :rails_health_check
end
