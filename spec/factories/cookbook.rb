FactoryGirl.define do
  factory :cookbook do
    association :category
    association :owner, factory: :user
    sequence(:name) { |n| "redis-#{n}" }
    source_url 'http://example.com'
    issues_url 'http://example.com/issues'
    deprecated false
    featured false

    transient do
      cookbook_versions_count 2
    end

    before(:create) do |cookbook, evaluator|
      cookbook.cookbook_versions << create_list(:cookbook_version, evaluator.cookbook_versions_count)
    end

    factory :partner_cookbook do
      sequence(:name) { |n| "partner-#{n}" }
      badges_mask 1
    end
  end
end
