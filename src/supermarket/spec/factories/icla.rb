FactoryBot.define do
  factory :icla do
    head { 'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod' }
    body { 'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod' }
    version { ENV['ICLA_VERSION'] }
  end
end
