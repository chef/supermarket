FactoryGirl.define do
  factory :user do
    first_name            'John'
    last_name             'Doe'
    phone                 '1234567890'
    password              'password'
    password_confirmation 'password'
    address_line_1        '123 Fake Street'
    city                  'Burlington'
    state                 'Vermont'
    zip                   '05401'
    country               'United States'

    sequence(:email) { |n| "johndoe#{n}@example.com" }

    factory :admin, class: User do
      first_name 'Admin'
      last_name  'User'
      roles_mask 1
    end
  end
end
