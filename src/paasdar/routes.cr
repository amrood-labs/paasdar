require "amber/dsl/router"
require "./controllers"

module Paasdar::Routes
  macro paasdar_for(resource)
    get "/{{ resource.id }}/sign_in", Paasdar::SessionsController, :new
    post "/{{ resource.id }}/sessions", Paasdar::SessionsController, :create
    get "/{{ resource.id }}/sign_out", Paasdar::SessionsController, :delete
  end
end

module Amber::DSL
  record Router, router : Amber::Router::Router, valve : Symbol, scope : String do
    include Paasdar::Routes
  end
end
