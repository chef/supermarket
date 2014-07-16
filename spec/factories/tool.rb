FactoryGirl.define do
  factory :tool do
    association :owner, factory: :user
    name 'butter'
    type 'ohai_plugin'
    description 'Great plugin for ohai.'
    source_url 'http://example.com'
    instructions 'Use with caution.'
  end
end
