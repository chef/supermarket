module ApiSpecHelpers
  def share_cookbook(args = {})
    cookbook_name = args[:cookbook] || 'redis-test-v1.tgz'
    category_name = (args[:category] || 'other').titleize

    tarball = fixture_file_upload("spec/support/cookbook_fixtures/#{cookbook_name}", 'application/x-gzip')
    category = create(:category, name: category_name)

    post '/api/v1/cookbooks', cookbook: "{\"category\": \"#{category_name}\"}", tarball: tarball
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
