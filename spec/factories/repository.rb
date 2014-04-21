FactoryGirl.define do
  factory :repository, class: Curry::Repository do
    owner 'gofullstack'
    name 'paprika'
    callback_url ENV['PUBSUBHUBBUB_CALLBACK_URL']
  end
end
