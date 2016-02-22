FactoryGirl.define do
  factory :cookbook_version do
    description 'An awesome cookbook!'
    license 'MIT'
    sequence(:version) { |n| "1.2.#{n}" }
    tarball { File.open('spec/support/cookbook_fixtures/redis-test-v1.tgz') }
    readme '# redis cookbook'
    readme_extension 'md'
    foodcritic_failure false

    trait :debian do
      after(:build) do |cookbook_version, evaluator|
        cookbook_version.add_supported_platform("debian", evaluator.version)
      end
    end
  end

  factory :debian_cookbook_version, parent: :cookbook_version do
    debian
  end
end
