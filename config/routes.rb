Rails.application.routes.draw do
  root 'tweets#timeline'
  get "/tweets" => "tweets#timeline"
  post "/favorites" => "tweets#favorite"
  delete "/favorites" => "tweets#unfavorite"
end
