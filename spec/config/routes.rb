Rails.application.routes.draw do
  resources :tests, only: [:index]
  get '/tests/blank' => 'tests#blank'
end
