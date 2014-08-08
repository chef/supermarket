module Universe
  COOKBOOK = 'cookbook'.freeze
  VERSION = 'version'.freeze
  DEPENDENCY = 'dependency'.freeze
  DEPENDENCY_CONSTRAINT = 'dependency_constraint'.freeze
  LOCATION_PATH = 'location_path'.freeze
  LOCATION_TYPE = 'location_type'.freeze
  DOWNLOAD_URL = 'download_url'.freeze
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

    cookbooks_to_filter = opts.fetch(:cookbooks, nil)

    if cookbooks_to_filter.present?
      sql = %(
        SELECT cookbook_versions.version,
          cookbooks.name AS cookbook,
          cookbook_dependencies.name AS dependency,
          cookbook_dependencies.version_constraint AS dependency_constraint
        FROM cookbook_versions
          INNER JOIN cookbooks ON cookbooks.id = cookbook_versions.cookbook_id
          LEFT JOIN cookbook_dependencies ON cookbook_dependencies.cookbook_version_id = cookbook_versions.id
        WHERE cookbooks.name ~ '#{cookbooks_to_filter.gsub(',', '|')}'
      )
    else
      sql = %(
        SELECT cookbook_versions.version,
          cookbooks.name AS cookbook,
          cookbook_dependencies.name AS dependency,
          cookbook_dependencies.version_constraint AS dependency_constraint
        FROM cookbook_versions
          INNER JOIN cookbooks ON cookbooks.id = cookbook_versions.cookbook_id
          LEFT JOIN cookbook_dependencies ON cookbook_dependencies.cookbook_version_id = cookbook_versions.id
      )
    end

    cookbooks = ActiveRecord::Base.connection.execute(sql).to_a

    cookbooks.reduce({}) do |result, row|
      name = row[COOKBOOK]
      version = row[VERSION]
      dependency = row[DEPENDENCY]
      dependency_constraint = row[DEPENDENCY_CONSTRAINT]
      url_base = protocol_host_port(opts)
      location_path = "#{url_base}/api/v1"

      result[name] ||= {}
      result[name][version] ||= {
        LOCATION_TYPE => OPSCODE,
        LOCATION_PATH => location_path,
        DOWNLOAD_URL => download_url(name, version, url_base),
        DEPENDENCIES => {}
      }

      if dependency && dependency_constraint
        result[name][version][DEPENDENCIES][dependency] = dependency_constraint
      end

      result
    end
  end

  #
  # Track a hit to the /universe endpoint
  #
  # The query below does a conditional insert/update. If a record doesn't
  # already exist in the hits table, then it will insert one, with an initial
  # hit count of 1. If a record already exists, then it
  # will increment the hit counter for 'universe'. Having all this in 1 query
  # is a bit dense, logic-wise, but it does eliminate needing to query first
  # and then conditionally insert/update.
  #
  # Again, doing this in raw sql instead of AR for performance reasons.
  #
  def track_hit
    sql = %(WITH upd AS
            (UPDATE hits SET total=total+1 WHERE label='universe' RETURNING *)
            INSERT INTO hits (label, total)
            SELECT 'universe', 1 WHERE NOT EXISTS (SELECT * FROM upd))
    ActiveRecord::Base.connection.execute(sql)
  end

  #
  # Show how many hits to the /universe endpoint
  #
  # Again, doing this in raw sql instead of AR for performance reasons.
  #
  def show_hits
    sql = "SELECT total FROM hits WHERE label='universe'"
    result = ActiveRecord::Base.connection.execute(sql).to_a.first
    result.nil? ? 0 : result['total'].to_i
  end

  #
  # Construct a full download URL
  #
  # @param cookbook [String] name of the cookbook
  # @param version [String] cookbook version
  # @param opts [Hash] an options hash containing optional overrides for host, port and
  # protocol
  #
  # @return [String] Cookbook's full download URL
  def download_url(cookbook, version, url_base)
    "#{url_base}/api/v1/cookbooks/#{cookbook}/versions/#{version}/download"
  end

  #
  # Construct the protocol, host, and port portion of the URLs used
  # for location_path and download_url
  #
  # @param cookbook [String] name of the cookbook
  # @param version [String] cookbook version
  # @param opts [Hash] an options hash containing optional overrides for host, port and
  # protocol
  #
  # @return [String] protocol://host:port
  def protocol_host_port(opts = {})
    host = opts.fetch(:host, ENV['HOST'])
    port = opts.fetch(:port, ENV['PORT'])
    # port may be nil or empty, and if so we don't want to have a port
    # string, but if not, then we want to prepend a colon for the URI
    # we return.
    port_string = port.nil? || port.to_s.empty? ? '' : ":#{port}"
    protocol = opts.fetch(:protocol, 'http')
    "#{protocol}://#{host}#{port_string}"
  end
end
