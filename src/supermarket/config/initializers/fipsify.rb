if ENV['OPENSSL_FIPS'] == "1"
  Supermarket::FIPS.enable!
  Rails.logger.info "FIPS 140-2 mode is enabled."
end
