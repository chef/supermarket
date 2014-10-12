require 'fileutils'
require 'securerandom'

# Manages configuration
class Supermarket
  module Config
    def self.generate_secrets!(filename)
      secrets = Chef::JSONCompat.from_json(File.open(filename).read)
    rescue Errno::ENOENT
      begin
        secrets = {
          'supermarket' => {
            'database' => { 'password' => SecureRandom.hex(50) }
          }
        }

        unless Dir.exist?(File.dirname(filename))
          FileUtils.mkdir(File.dirname(filename), :mode => 0700)
        end

        open(filename, 'w') do |file|
          file.puts Chef::JSONCompat.to_json_pretty(secrets)
          file.chmod 0600
        end

        secrets
      rescue Errno::EACCES => e
        Chef::Log.warn "Could not create #{filename}: #{e}"
        secrets
      end
    end
  end
end
