FactoryGirl.define do
  factory :ccla do
    head 'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod'
    body 'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod'
    version Supermarket::Config.ccla_version
  end
end
