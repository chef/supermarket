FactoryGirl.define do
  factory :cookbook do
    association :category
    sequence(:name) { |n| "redis-#{n}" }
    description 'An awesome cookbook!'
    maintainer 'Chef Software, Inc'
    source_url 'http://example.com'
    issues_url 'http://example.com/issues'
    deprecated false

    ignore do
      cookbook_versions_count 2
    end

    before(:create) do |cookbook, evaluator|
      cookbook.cookbook_versions << build_list(:cookbook_version, evaluator.cookbook_versions_count, cookbook: cookbook)
    end
  end
end
