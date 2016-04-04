module Supermarket
  module Host
    def self.full_url
      if ENV['PORT'].present? && !%w(80 443).include?(ENV['PORT'])
        "#{ENV['PROTOCOL']}://#{ENV['HOST']}:#{ENV['PORT']}"
      else
        "#{ENV['PROTOCOL']}://#{ENV['HOST']}"
      end
    end
  end
end
