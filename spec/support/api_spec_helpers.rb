require 'and_feathers'
require 'and_feathers/gzipped_tarball'
require 'tempfile'

module ApiSpecHelpers
  def share_cookbook(cookbook_name, options = {})
    category_name = options.fetch(:category, 'other').titleize
    custom_metadata = options.dup.tap { |o| o.delete(:category) }

    metadata = {
      name: cookbook_name,
      version: '1.0.0',
      description: "Installs/Configures #{cookbook_name}",
      maintainer: 'Chef Software, Inc',
      license: 'MIT',
      platforms: {
        'ubuntu' => '>= 12.0.0'
      },
      dependencies: {
        'apt' => '~> 1.0.0'
      }
    }.merge(custom_metadata)

    tarball = Tempfile.new([cookbook_name, '.tgz'], 'tmp').tap do |file|
      io = AndFeathers.build(cookbook_name) do |base_dir|
        base_dir.file('README.md') { '# README' }
        base_dir.file('metadata.json') do
          JSON.dump(metadata)
        end
      end.to_io(AndFeathers::GzippedTarball)

      file.write(io.read)
      file.rewind
    end

    tarball_upload = fixture_file_upload(tarball.path, 'application/x-gzip')
    category = create(:category, name: category_name)

    post '/api/v1/cookbooks', cookbook: "{\"category\": \"#{category_name}\"}", tarball: tarball_upload
  end

  def json_body
    JSON.parse(response.body)
  end

  def signature(resource)
    resource.except('created_at', 'updated_at', 'file', 'tarball_file_size')
  end

  def error_404
    {
       'error_messages' => ['Resource does not exist'],
       'error_code' => 'NOT_FOUND'
    }
  end

  def publish_version(cookbook, version)
    create(
      :cookbook_version,
      cookbook: cookbook,
      version: version
    )
  end
end
