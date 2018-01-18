require_relative 'tarball_helpers'
require 'mixlib/authentication/signedheaderauth'

module ApiSpecHelpers
  #
  # Shares a cookbook with a given name and options using the /api/v1/cookbooks API.
  #
  # @param cookbook_name [String] the name of the cookbook to be shared
  # @param user [User] the user that's sharing the cookbook
  # @param opts [Hash] options that determine the contents of the tarball, signed header and request payload
  #
  # @option opts [Hash] :custom_metadata Custom values/attributes for the cookbook metadata
  # @option opts [Boolean] :with_invalid_public_key Make request with an invalid public key
  # @option opts [Array] :omitted_headers Any headers to omit from the signed request
  # @option opts [String] :category The category to share the cookbook to
  # @option opts [String] :payload a JSON representation of the request body
  #
  def share_cookbook(cookbook_name, user, opts = {})
    cookbooks_path = '/api/v1/cookbooks'
    cookbook_params = {}

    tarball = cookbook_upload(cookbook_name, opts)
    private_key = private_key(opts.fetch(:with_invalid_private_key, false))

    header = Mixlib::Authentication::SignedHeaderAuth.signing_object(
      http_method: 'post',
      path: cookbooks_path,
      user_id: user.username,
      timestamp: Time.current.utc.iso8601,
      body: tarball.read
    ).sign(private_key)

    opts.fetch(:omitted_headers, []).each { |h| header.delete(h) }

    category = opts.fetch(:category, 'other')

    unless category.nil?
      new_category = create(:category, name: category.titleize)
      cookbook_params[:category] = new_category.name
    end

    payload = opts.fetch(:payload, cookbook: JSON.generate(cookbook_params), tarball: tarball)

    post cookbooks_path, params: payload, headers: header
  end

  #
  # Unshares a cookbook with a given name using the /api/v1/cookbooks/:cookbook API.
  #
  # @param cookbook_name [String] the name of the cookbook to be unshared
  # @param user [User] the user that's unsharing the cookbook
  #
  def unshare_cookbook(cookbook_name, user)
    cookbook_path = "/api/v1/cookbooks/#{cookbook_name}"

    header = Mixlib::Authentication::SignedHeaderAuth.signing_object(
      http_method: 'delete',
      path: cookbook_path,
      user_id: user.username,
      timestamp: Time.current.utc.iso8601,
      body: ''
    ).sign(private_key)

    delete cookbook_path, params: {}, headers: header
  end

  #
  # Unshares a cookbook version with a given name using the /api/v1/cookbooks/:cookbook/versions/:version API.
  #
  # @param cookbook_name [String] the name of the cookbook version to be unshared
  # @param cookbook_version [String] the version of the cookbook to be unshared
  # @param user [User] the user that's unsharing the cookbook version
  #
  def unshare_cookbook_version(cookbook_name, version, user)
    cookbook_version_path = "/api/v1/cookbooks/#{cookbook_name}/versions/#{version}"

    header = Mixlib::Authentication::SignedHeaderAuth.signing_object(
      http_method: 'delete',
      path: cookbook_version_path,
      user_id: user.username,
      timestamp: Time.current.utc.iso8601,
      body: ''
    ).sign(private_key)

    delete cookbook_version_path, params: {}, headers: header
  end

  def json_body
    JSON.parse(response.body)
  end

  def signature(resource)
    resource.except('created_at', 'updated_at', 'file', 'tarball_file_size')
  end

  def error_404
    {
      'error_messages' => [I18n.t('api.error_messages.not_found')],
      'error_code' => I18n.t('api.error_codes.not_found')
    }
  end

  def publish_version(cookbook, version)
    create(
      :cookbook_version,
      cookbook: cookbook,
      version: version
    )
  end

  private

  def private_key(invalid = false)
    key_name = invalid ? 'invalid_private_key.pem' : 'valid_private_key.pem'

    OpenSSL::PKey::RSA.new(
      File.read("spec/support/key_fixtures/#{key_name}")
    )
  end

  def cookbook_upload(cookbook_name, opts = {})
    begin
      if cookbook_name.ends_with?('.tgz')
        tarball = File.new(Rails.root.join('spec', 'support', 'cookbook_fixtures', cookbook_name))
      else
        custom_metadata = opts.fetch(:custom_metadata, {})

        metadata = {
          name: cookbook_name,
          version: '1.0.0',
          description: "Installs/Configures #{cookbook_name}",
          license: 'MIT',
          platforms: {
            'ubuntu' => '>= 12.0.0'
          },
          dependencies: {
            'apt' => '~> 1.0.0'
          }
        }.merge(custom_metadata)

        tarball = build_cookbook_tarball(cookbook_name) do |base_dir|
          base_dir.file('README.md') { '# README' }
          base_dir.file('metadata.json') do
            JSON.dump(metadata)
          end
        end
      end

      content_type = opts.fetch(:content_type, 'application/x-gzip')
      fixture_file_upload(tarball.path, content_type)
    ensure
      tarball.close
    end
  end
end
