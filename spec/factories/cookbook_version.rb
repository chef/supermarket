FactoryGirl.define do
  factory :cookbook_version do
    association :cookbook

    license 'MIT'
    sequence(:version) { |n| "1.2.#{n}" }
    tarball { File.open('spec/support/cookbook_fixtures/redis-test-v1.tgz') }
    readme '# redis cookbook'
    readme_extension 'md'
  end
end
