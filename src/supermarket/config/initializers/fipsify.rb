if ENV["OPENSSL_FIPS"] == "1"
  # Ensure the Fips class is loaded before calling it
  # Use a more Rails 7.1 compatible approach for autoloading
  Rails.application.config.to_prepare do
    Supermarket::Fips.enable!
    Rails.logger.info "FIPS 140-2 mode is enabled and verified."
  rescue OpenSSL::OpenSSLError => e
    Rails.logger.error "FIPS mode requested but configuration failed: #{e.message}"
    Rails.logger.error "OpenSSL 3+ FIPS Configuration Required:"
    Rails.logger.error "1. Ensure OpenSSL is compiled with FIPS support"
    Rails.logger.error "2. Configure openssl.cnf with FIPS provider enabled"
    Rails.logger.error "3. Set OPENSSL_CONF environment variable to point to your openssl.cnf"
    Rails.logger.error "4. Restart the application after configuration"
    raise e # Fail fast - don't continue without FIPS when explicitly requested
  end
end
