FactoryGirl.define do
  factory :address do
    association    :user
    address_line_1 '123 Some Street'
    address_line_2 'Apartment #1'
    city           'Pittsburgh'
    state          'PA'
    zip            '15217'
    country        'United States'
  end
end
