if ENV["OPENSSL_FIPS"] == "1"
  Supermarket::Fips.enable!
  Rails.logger.info "FIPS 140-2 mode is enabled."
end
