FactoryBot.define do
  factory :icla_signature do
    association :user

    prefix { 'Mr.' }
    first_name { 'John' }
    middle_name { 'A.' }
    last_name { 'Doe' }
    suffix { 'Sr.' }
    phone { '1234567890' }
    email { 'jdoe@example.com' }

    address_line_1 { '123 Some Street' }
    address_line_2 { 'Apartment #5' }
    city { 'Pittsburgh' }
    state { 'PA' }
    zip { '15213' }
    country { 'United States' }

    agreement { '1' }
  end
end
