FactoryGirl.define do
  factory :repository, class: Curry::Repository do
    owner        'cramerdev'
    name         'paprika'
    callback_url Supermarket::Config.pubsubhubbub['callback_url']
  end
end
