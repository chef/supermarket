module Supermarket
  module Host
    def self.full_url
      if ENV['PORT'].present?
        "#{ENV['PROTOCOL']}://#{ENV['HOST']}:#{ENV['PORT']}"
      else
        "#{ENV['PROTOCOL']}://#{ENV['HOST']}"
      end
    end
  end
end
