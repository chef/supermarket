FactoryGirl.define do
  factory :cookbook do
    name 'redis'
    description 'An awesome cookbook!'
    maintainer 'Chef Software Inc'
    category 'datastore'
    external_url 'http://example.com'
    deprecated false
  end
end
