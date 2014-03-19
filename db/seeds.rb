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

Icla.where(version: Supermarket::Config.icla_version).
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

Ccla.where(version: Supermarket::Config.ccla_version).
  first_or_create!.
  update_attributes(attributes)

if Rails.env.development?
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
      maintainer: '...',
      description: '...',
      category: category
    )

    cookbook_version = cookbook.cookbook_versions.where(
      version: '0.1.0'
    ).first_or_initialize(
      license: 'MIT',
      cookbook: cookbook,
      tarball: File.open('spec/support/cookbook_fixtures/redis-test-v1.tgz')
    )

    cookbook.cookbook_versions << cookbook_version
    cookbook.save!
  end
end
