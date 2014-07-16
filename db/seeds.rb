#
# The Default ICLA Document
#
# Get assign the head.md and body.md Markdown documents in the seeds directory
# to their respective attributes and create an Icla with the configured
# version.
#
attributes = {}

%w(head body).each do |section|
  attributes[section] = open(
    "#{File.dirname(__FILE__)}/seeds/icla/#{section}.md"
  ).read
end

Icla.where(version: ENV['ICLA_VERSION']).
  first_or_create!.
  update_attributes(attributes)

#
# The Default CCLA Document
#
# Get assign the head.md and body.md Markdown documents in the seeds directory
# to their respective attributes and create an Ccla with the configured
# version.
#
%w(head body).each do |section|
  attributes[section] = open(
    "#{File.dirname(__FILE__)}/seeds/ccla/#{section}.md"
  ).read
end

Ccla.where(version: ENV['CCLA_VERSION']).
  first_or_create!.
  update_attributes(attributes)

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
  # Default ICLA Signature for use in development.
  #
  user.icla_signatures.where(
    first_name: 'John',
    last_name: 'Doe',
    email: 'john@example.com',
    phone: '888-555-5555',
    address_line_1: '123 Fake Street',
    city: 'Burlington',
    state: 'Vermont',
    zip: '05401',
    country: 'United States'
  ).first_or_create!(agreement: '1')

  #
  # Default Organization for use in development.
  #
  organization = Organization.first_or_create

  #
  # Default CCLA Signature for use in development.
  #
  user.ccla_signatures.where(
    first_name: 'John',
    last_name: 'Doe',
    email: 'john@example.com',
    phone: '888-555-5555',
    address_line_1: '123 Fake Street',
    city: 'Burlington',
    state: 'Vermont',
    zip: '05401',
    country: 'United States',
    company: 'Chef',
    organization: organization
  ).first_or_create!(agreement: '1')

  #
  # Default Invitation for use in development.
  #
  invitation = Invitation.where(
    email: 'johndoe@example.com',
    organization: organization
  ).first_or_create!

  #
  # Default category for use in development.
  #
  category = Category.where(name: 'Other').first_or_create!

  #
  # Default cookbooks for use in development.
  #
  %w(redis postgres node ruby haskell clojure java mysql apache2 nginx yum apt).each do |name|
    cookbook = Cookbook.where(
      name: name
    ).first_or_initialize(
      source_url: 'http://example.com',
      issues_url: 'http://example.com',
      category: category,
      owner: user
    )

    # TODO: figure out a nice way to use CookbookUpload here, which will ensure
    # that our seed data is realistically seeded.
    cookbook_version = cookbook.cookbook_versions.where(
      version: '0.1.0'
    ).first_or_create(
      description: Faker::Lorem.sentences(1).first,
      license: 'MIT',
      tarball: File.open('spec/support/cookbook_fixtures/redis-test-v1.tgz'),
      readme: File.read('README.md'),
      readme_extension: 'md'
    )

    cookbook.cookbook_versions << cookbook_version
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
      user: user
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
      instructions: "Install the plugin in /etc/chef/ohai_plugins.",
      user: user
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
