# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# The Default ICLA Document
parts = %w[ head body ].inject({}) do |result, part|
  result[part] = open(File.dirname(__FILE__) + "/seeds/icla/#{part}.md").read
  result
end

Icla.find_or_create_by_version(Supermarket::Config.icla_version).update_attributes(parts)
