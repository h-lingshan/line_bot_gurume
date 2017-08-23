Rails.application.routes.draw do
  get 'webhook/index'
  post '/callback' => 'webhook#callback'
  get '/callback' => 'webhook#callback'
  root 'webhook#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
