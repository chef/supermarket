FactoryGirl.define do
  factory :user do
    prefix      'Mr.'
    first_name  'John'
    middle_name 'A.'
    last_name   'Doe'
    suffix      'Sr.'
    phone       '1234567890'

    sequence(:username) { |n| "johndoe_#{n}" }
  end
end
