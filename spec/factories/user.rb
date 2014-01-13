FactoryGirl.define do
  factory :user do
    prefix      'Mr.'
    first_name  'John'
    middle_name 'A.'
    last_name   'Doe'
    suffix      'Sr.'
    phone       '1234567890'

    sequence(:username) { |n| "johndoe_#{n}" }

    factory :admin, class: User do
      first_name 'Admin'
      last_name  'User'
      roles_mask 1
    end
  end
end
