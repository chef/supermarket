FactoryGirl.define do
  factory :cookbook_version do
    association :cookbook

    description 'An awesome cookbook!'
    license 'MIT'
    version '1.2.0'
    tarball { File.open('spec/support/cookbook_fixtures/redis-test-v1.tgz') }
  end
end
