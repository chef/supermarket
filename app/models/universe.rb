module Universe
  COOKBOOK = 'cookbook'.freeze
  VERSION = 'version'.freeze
  DEPENDENCY = 'dependency'.freeze
  DEPENDENCY_CONSTRAINT = 'dependency_constraint'.freeze
  LOCATION_PATH = 'location_path'.freeze
  LOCATION_TYPE = 'location_type'.freeze
  DEPENDENCIES = 'dependencies'.freeze
  OPSCODE = 'opscode'.freeze

  module_function

  #
  # Generate the Hash required for the /universe API endpoint.
  #
  # @return [Hash] the universe hash
  #
  def generate(opts = {})
    #
    # So yeah, why are we using SQL here instead of our friend ActiveRecord?
    # Turns out, when you're retrieving a lot of objects at once, and joining
    # objects on foreign keys, AR is really slow - prohibitively slow for what
    # we're doing. Writing this with SQL and iterating over an array of hashes
    # gives us roughly a 20x performance improvement over using ActiveRecord,
    # which is worth it in this case. We're also generating the URL by hand
    # instead of using the Rails URL helpers, because the URL helpers are slow,
    # and we're calling it in a loop.
    #

    sql = %(
      SELECT cookbook_versions.version,
        cookbooks.name AS cookbook,
        cookbook_dependencies.name AS dependency,
        cookbook_dependencies.version_constraint AS dependency_constraint
      FROM cookbook_versions
        INNER JOIN cookbooks ON cookbooks.id = cookbook_versions.cookbook_id
        LEFT JOIN cookbook_dependencies ON cookbook_dependencies.cookbook_version_id = cookbook_versions.id
    )

    cookbooks = ActiveRecord::Base.connection.execute(sql).to_a

    cookbooks.reduce({}) do |result, row|
      name = row[COOKBOOK]
      version = row[VERSION]
      dependency = row[DEPENDENCY]
      dependency_constraint = row[DEPENDENCY_CONSTRAINT]

      result[name] ||= {}
      result[name][version] ||= {
        LOCATION_TYPE => OPSCODE,
        LOCATION_PATH => download_path(name, version, opts),
        DEPENDENCIES => {}
      }

      if dependency && dependency_constraint
        result[name][version][DEPENDENCIES][dependency] = dependency_constraint
      end

      result
    end
  end

  #
  # Construct a download path URL by hand for performance reasons
  #
  # @param cookbook [String] name of the cookbook
  # @param version [String] cookbook version
  # @param opts [Hash] an options hash containing optional overrides for host, port and
  # protocol
  #
  # @return [String] Cookbook download URL
  #
  def download_path(cookbook, version, opts = {})
    host = opts.fetch(:host, ENV['HOST'])
    port = opts.fetch(:port, ENV['PORT'])
    # port may be nil or empty, and if so we don't want to have a port
    # string, but if not, then we want to prepend a colon for the URI
    # we return.
    port_string = port.nil? || port.to_s.empty? ? '' : ":#{port}"
    protocol = opts.fetch(:protocol, 'http')
    "#{protocol}://#{host}#{port_string}/api/v1"
  end
end
