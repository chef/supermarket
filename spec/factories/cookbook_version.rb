FactoryGirl.define do
  factory :cookbook_version do
    description 'An awesome cookbook!'
    maintainer 'Chef Software, Inc'
    license 'MIT'
    sequence(:version) { |n| "1.2.#{n}" }
    tarball { File.open('spec/support/cookbook_fixtures/redis-test-v1.tgz') }
    readme '# redis cookbook'
    readme_extension 'md'
  end
end
