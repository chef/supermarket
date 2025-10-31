require "digest"
require "openssl"

module Supermarket
  class Fips
    # FIPS 140-2 Annex A references NIST Digital Signature Standard (DSS),
    # FIPS Publication 186-4 to identify several algorithms as the
    # Secure Hash Standard (SHS). Algorithms listed here are in the SHS
    # and are used in various places in the Rails framework.
    SECURE_HASHES = %w{SHA1 SHA256 SHA512}.freeze

    def self.enable!
      # OpenSSL 3+ FIPS mode cannot be programmatically enabled/disabled
      # FIPS is controlled by omnibus configuration and openssl.cnf at process startup
      # We configure the application for FIPS compliance when requested
      if ENV["OPENSSL_FIPS"] == "1"
        Rails.logger.info "FIPS mode requested via OPENSSL_FIPS environment variable"
        Rails.logger.info "Configuring application for FIPS compliance"
      else
        Rails.logger.debug "FIPS mode not requested, using standard configuration"
      end
      # Always use OpenSSL digest algorithms for better FIPS compliance
      use_openssl_hash_algorithms!
    end

    def self.use_openssl_hash_algorithms!
      # Most of Ruby's standard Digest algorithms will error when used
      # in FIPS mode because their implementation is not in a
      # FIPS-approved library.
      # Reroute calls to Ruby Digest's hash algorithms to use the OpenSSL
      # library's algorithms which are allowed when compiled with the
      # OpenSSL FIPS Object Model adjunct.
      SECURE_HASHES.each do |algorithm|
        Digest.send(:remove_const, algorithm) if Digest.const_defined?(algorithm)
        Digest.const_set(algorithm, OpenSSL::Digest(algorithm))
      end
    end
  end
end
