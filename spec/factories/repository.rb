FactoryGirl.define do
  factory :repository, class: Curry::Repository do
    owner        'gofullstack'
    name         'paprika'
    callback_url Supermarket::Config.pubsubhubbub['callback_url']
  end
end
