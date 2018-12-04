require 'fileutils'
require 'securerandom'

# Manages configuration
class Supermarket
  module Config
    class IncompleteConfig < StandardError; end
    class IncompatibleConfig < StandardError; end

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
        Chef::Log.info("Creating configuration file #{filename}")
      end
    rescue Errno::ENOENT => e
      Chef::Log.warn "Could not create #{filename}: #{e}"
    end

    # Read in a JSON file for attributes and consume them
    def self.load_from_json!(filename, node)
      create_directory!(filename)
      if File.exist?(filename)
        node.consume_attributes(
          'supermarket' => Chef::JSONCompat.from_json(open(filename).read)
        )
      end
    rescue => e
      Chef::Log.warn "Could not read attributes from #{filename}: #{e}"
    end

    # Read in the filename (as JSON) and add its attributes to the node object.
    # If it doesn't exist, create it with generated secrets.
    def self.load_or_create_secrets!(filename, node)
      create_directory!(filename)
      secrets = Chef::JSONCompat.from_json(File.open(filename).read)
    rescue Errno::ENOENT
      begin
        secrets = { 'secret_key_base' => SecureRandom.hex(50) }

        open(filename, 'w') do |file|
          file.puts Chef::JSONCompat.to_json_pretty(secrets)
        end
        Chef::Log.info("Creating secrets file #{filename}")
      rescue Errno::EACCES, Errno::ENOENT => e
        Chef::Log.warn "Could not create #{filename}: #{e}"
      end

      node.consume_attributes('supermarket' => secrets)
    end

    def self.audit_config(node)
      required_s3_vars = %w(s3_bucket s3_access_key_id s3_secret_access_key s3_region).freeze
      any_s3_settings = required_s3_vars.any? { |key| !(node[key].nil? || node[key].empty?) }
      all_s3_settings = required_s3_vars.all? { |key| !(node[key].nil? || node[key].empty?) }

      if any_s3_settings && !all_s3_settings
        raise IncompleteConfig, "Got some, but not all, of the required S3 configs. Must provide none or all of #{required_s3_vars} to configure cookbook storage in an S3 bucket."
      end

      if node['s3_bucket'] =~ /\./ &&
         (node['s3_domain_style'] != ':s3_path_url' || node['s3_region'] != 'us-east-1')
        raise IncompatibleConfig, "Incompatible S3 bucket settings. If the bucket name contains periods, the bucket must be in us-east-1 and the domain style must be :s3_path_url.\nAmazon recommends against periods in bucket names. See: https://docs.aws.amazon.com/AmazonS3/latest/dev/BucketRestrictions.html"
      end
    end

    # Take some node attributes and return them on each line as:
    #
    # export ATTR_NAME="attr_value"
    #
    # If the value is a String or Number and the attribute name is attr_name.
    # Used to write out environment variables to a file.
    def self.environment_variables_from(attributes)
      attributes.reduce '' do |str, attr|
        str << if attr[1].is_a?(String) || attr[1].is_a?(Numeric) || attr[1] == true || attr[1] == false
                 "export #{attr[0].upcase}=\"#{attr[1]}\"\n"
               else
                 ''
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
