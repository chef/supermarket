QualityMetric.reset_column_information

QualityMetric.where(name: 'Cookstyle').first_or_create!
QualityMetric.where(name: 'Collaborator Number').first_or_create!
QualityMetric.where(name: 'License').first_or_create!
QualityMetric.where(name: 'Contributing File').first_or_create!
QualityMetric.where(name: 'Testing File').first_or_create!
QualityMetric.where(name: 'Version Tag').first_or_create!
QualityMetric.where(name: 'No Binaries').first_or_create!

#
# Default category
#
category = Category.where(name: 'Other').first_or_create!

[
  'New cookbook version',
  'Cookbook deleted',
  'Cookbook deprecated'
].each { |name| SystemEmail.where(name: name).first_or_create! }

if Rails.env.development?

  #
  # Default user for use in development.
  #
  user = User.where(
    first_name: 'John',
    last_name: 'Doe',
    email: 'john@example.com'
  ).first_or_create!

  #
  # Default account for use in development.
  #
  Account.where(
    username: 'johndoe',
    provider: 'github'
  ).first_or_create!(
    user: user,
    uid: '123',
    oauth_token: '123',
    oauth_secret: '123',
    oauth_expires: Date.parse('Tue, 20 Feb 2024')
  )

  Account.where(
    username: 'johndoe',
    provider: 'chef_oauth2'
  ).first_or_create!(
    user: user,
    uid: '456',
    oauth_token: '123',
    oauth_secret: '123',
    oauth_expires: Date.parse('Tue, 20 Feb 2024')
  )

  #
  # Default cookbooks for use in development.
  #
  platforms = {
    'app' => %w(windows ubuntu),
    'apt' => %w(debian ubuntu),
    'postgres' => %w(fedora debian suse amazon centos redhat scientific oracle ubuntu)
  }

  Cookbook.reset_column_information
  CookbookVersion.reset_column_information

  %w(apt redis postgres node ruby haskell clojure java mysql apache2 nginx yum app).each do |name|
    cookbook = Cookbook.where(
      name: name
    ).first_or_create(
      source_url: 'http://example.com',
      issues_url: 'http://example.com',
      category: category,
      owner: user
    )

    (1..2).each do |version_number|
      # TODO: figure out a nice way to use CookbookUpload here, which will ensure
      # that our seed data is realistically seeded.
      cookbook_version = cookbook.cookbook_versions.where(
        version: "0.#{version_number}.0"
      ).first_or_initialize(
        description: Faker::Lorem.sentences(number: 1).first,
        license: 'MIT',
        tarball: File.open('spec/support/cookbook_fixtures/redis-test-v1.tgz'),
        readme: '# This is a README',
        readme_extension: 'md',
        user: user
      )

      if platforms.key?(name)
        platforms[name].each do |platform|
          unless(cookbook_version.supported_platforms.where(name: platform, version_constraint: ">=#{version_number}.0").any?)
            cookbook_version.add_supported_platform(platform, ">=#{version_number}.0")
          end
        end
      end

      cookbook.save!

      unless name == 'apt' || name == 'yum'
        dep = version_number.even? ? 'apt' : 'yum'
        dependency = CookbookDependency.where(
          name: "#{dep} #{version_number} #{Time.now}",
          cookbook: Cookbook.find_by(name: dep),
          cookbook_version: cookbook_version
        ).first_or_create!
        cookbook_version.cookbook_dependencies << dependency
      end

      cookbook.cookbook_versions << cookbook_version
    end
    cookbook.save!
  end

  #
  # Default knife plugins (tools) for use in development.
  #
  %w(knife-supermarket knife-ec2 knife-openstack knife-cloud knife-rackspace).each do |name|
    tool = Tool.where(
      name: name
    ).first_or_create(
      type: 'knife_plugin',
      description: 'Great knife plugin.',
      source_url: 'http://example.com',
      instructions: "gem install #{name}",
      owner: user
    )
  end

  #
  # Default ohai plugins (tools) for use in development.
  #
  %w(dell dpkg ipmi ladvd rpm).each do |name|
    tool = Tool.where(
      name: name
    ).first_or_create(
      type: 'ohai_plugin',
      description: 'Great ohai plugin.',
      source_url: 'http://example.com',
      instructions: 'Install the plugin in /etc/chef/ohai_plugins.',
      owner: user
    )
  end

  #
  # Default cookbook folower for use in development.
  #
  CookbookFollower.where(
    user: user,
    cookbook: Cookbook.find_by(name: 'redis')
  ).first_or_create!
end
