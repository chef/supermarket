require 'fileutils'
require 'securerandom'

# Manages configuration
class Supermarket
  module Config
    def self.load_or_create!(filename, node)
      create_directory!(filename)
      if File.exist?(filename)
        node.from_file(filename)
      else
        # Write out the new file, but with everything commented out
        File.open(filename, 'w') do |file|
          File.open(
            "#{node['supermarket']['install_directory']}/embedded/cookbooks/omnibus-supermarket/attributes/default.rb", 'r'
          ).read.each_line do |line|
            file.write "# #{line}"
          end
        end
      end
    rescue Errno::ENOENT => e
      Chef::Log.warn "Could not create #{filename}: #{e}"
    end

    # Read in the filename (as JSON) and add its attributes to the node object.
    # If it doesn't exist, create it with generated secrets.
    def self.load_or_create_secrets!(filename, node)
      create_directory!(filename)
      secrets = Chef::JSONCompat.from_json(File.open(filename).read)
    rescue Errno::ENOENT
      begin
        secrets = {
          'supermarket' => {

          }
        }

        open(filename, 'w') do |file|
          file.puts Chef::JSONCompat.to_json_pretty(secrets)
        end
      rescue Errno::EACCES, Errno::ENOENT => e
        Chef::Log.warn "Could not create #{filename}: #{e}"
      end

      node.consume_attributes(secrets)
    end

    # Take some node attributes and return them on each line as:
    #
    # export ATTR_NAME="attr_value"
    #
    # If the value is a String or Number and the attribute name is attr_name.
    # Used to write out environment variables to a file.
    def self.environment_variables_from(attributes)
      attributes.reduce "" do |str, attr|
        if attr[1].is_a?(String) || attr[1].is_a?(Numeric)
          str << "export #{attr[0].upcase}=\"#{attr[1]}\"\n"
        else
          str << ''
        end
      end
    end

    def self.create_directory!(filename)
      dir = File.dirname(filename)
      FileUtils.mkdir(dir, :mode => 0700) unless Dir.exist?(dir)
    rescue Errno::EACCES => e
      Chef::Log.warn "Could not create #{dir}: #{e}"
    end
    private_class_method :create_directory!
  end
end
