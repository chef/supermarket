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

if ENV['SEED_CLA_DATA']
  #
  # Add 100 new individual contributors
  #
  existing_contributors = User.authorized_contributors.map(&:id)

  individual_contributors = User.where.not(id: existing_contributors).first(100)

  ActiveRecord::Base.transaction do
    individual_contributors.each.with_index do |user, index|
      IclaSignature.create!(
        user: user,
        icla: Icla.first,
        first_name: user.first_name || 'Anonymous',
        last_name: user.last_name || "Contributor #{index}",
        email: user.email,
        phone: '(555) 555-5555',
        address_line_1: '1 Main St.',
        city: 'Whoville',
        state: 'NY',
        zip: '12345',
        country: 'USA',
        agreement: '1'
      )
    end
  end

  #
  # Add 25 new CCLA signatures
  #
  existing_contributors += individual_contributors.map(&:id)

  ccla_signers = User.where.not(id: existing_contributors).first(25)
  ccla_signatures = ccla_signers.map.with_index do |user, index|
    CclaSignature.new(
      user: user,
      ccla: Ccla.first,
      first_name: user.first_name || 'Anonymous',
      last_name: user.last_name || 'Contributor',
      email: user.email,
      phone: '(555) 555-5555',
      company: "Contributing Company #{index}",
      address_line_1: '1 Main St.',
      city: 'Whoville',
      state: 'NY',
      zip: '12345',
      country: 'USA',
      agreement: '1'
    )
  end

  ActiveRecord::Base.transaction do
    ccla_signatures.map! { |signature| signature.tap(&:sign!) }
  end

  #
  # Add 50 of the new individual contributors as contributors on behalf of one
  # of the new CCLA signatures
  #
  existing_contributors += ccla_signers.map(&:id)

  ActiveRecord::Base.transaction do
    individual_contributors.shuffle.first(50).each.with_index do |user, index|
      ccla_signatures[index % ccla_signatures.size].tap do |ccla_signature|
        ccla_signature.organization.contributors.create!(user: user)
      end
    end
  end

  #
  # Add 100 new corporate contributors contributors on behalf of one of the new
  # CCLA signatures
  #
  corporate_contributors = User.where.not(id: existing_contributors).first(100)

  ActiveRecord::Base.transaction do
    corporate_contributors.each.with_index do |user, index|
      ccla_signatures[index % ccla_signatures.size].tap do |ccla_signature|
        ccla_signature.organization.contributors.create!(user: user)
      end
    end
  end
end

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
  organization.admins.where(user_id: user.id).first_or_create

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
      instructions: "Install the plugin in /etc/chef/ohai_plugins.",
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
