KothariAPI::Router::Router.draw do |r|
  r.get "/", to: "home#index"
  r.get "/blog", to: "blog#index"
  r.get "/comments", to: "comments#index"
  r.post "/comments", to: "comments#create"
  r.post "/signup", to: "auth#signup"
  r.post "/login", to: "auth#login"
end
