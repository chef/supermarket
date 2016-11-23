require 'sidekiq'
require 'net/http'

class LicenseWorker
  include ::Sidekiq::Worker
end
