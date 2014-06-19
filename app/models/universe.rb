module Universe
  module_function

  #
  # Generate the Hash required for the /universe API endpoint.
  #
  # @return [Hash] the universe hash
  #
  def generate(opts = {})
    host = Supermarket::Config.host
    protocol = opts.fetch(:ssl, false) ? 'https' : 'http'

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
      name = row['cookbook']
      version = row['version']

      dhash = if row['dependency'].present? && row['dependency_constraint'].present?
                { row['dependency'] => row['dependency_constraint'] }
              else
                {}
              end

      vhash = {
        version => {
          'location_path' => download_path(name, version, host, protocol),
          'location_type' => 'supermarket',
          'dependencies' => dhash
        }
      }

      if result.key?(name)
        existing_vhash = result[name]

        if existing_vhash.key?(version)
          result[name][version]['dependencies'].merge!(dhash)
        else
          result[name].merge!(vhash)
        end
      else
        result[name] = vhash
      end

      result
    end
  end

  #
  # Construct a download path URL by hand for performance reasons
  #
  # @param cookbook [String] name of the cookbook
  # @param version [String] cookbook version
  # @param host [String] Rails host
  # @param protocol [String] http or https
  #
  # @return [String] Cookbook download URL
  #
  def download_path(cookbook, version, host, protocol)
    "#{protocol}://#{host}/api/v1/cookbooks/#{cookbook}/versions/#{version}/download"
  end
end
