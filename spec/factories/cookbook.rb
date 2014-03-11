FactoryGirl.define do
  factory :cookbook do
    association :category
    name 'redis'
    description 'An awesome cookbook!'
    maintainer 'Chef Software, Inc'
    external_url 'http://example.com'
    deprecated false
  end
end
