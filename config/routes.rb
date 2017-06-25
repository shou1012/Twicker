Rails.application.routes.draw do
  root 'home#index'
  get "home/index"

  # twitter routes
  get "/tweets" => "tweets#timeline"
  get "/signout_twitter" => "sessions#destroy"

  get "/auth/:provider/callback" => "sessions#create"
end
