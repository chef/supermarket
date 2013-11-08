# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# The Default ICLA Document
#
# Get assign the head.md and body.md Markdown documents in the seeds directory
# to their respective attributes and create an Icla with the configured
# version.
attributes = {}

%w[ head body ].each do |section|
  attributes[section] = open(
    "#{File.dirname(__FILE__)}/seeds/icla/#{section}.md"
  ).read
end

Icla.find_or_create_by_version(Supermarket::Config.icla_version).
  update_attributes(attributes)
