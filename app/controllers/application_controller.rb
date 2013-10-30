class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  include Supermarket::Authentication
  include Supermarket::Authorization
end
