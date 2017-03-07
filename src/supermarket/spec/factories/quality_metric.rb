FactoryGirl.define do
  factory :quality_metric, class: 'QualityMetric' do
    trait :foodcritic do
      name "Foodcritic"
    end

    trait :collaborator_num do
      name "Collaborator Number"
    end

    trait :publish do
      name "Publish"
    end

    trait :license do
      name "License"
    end

    trait :supported_platforms do
      name "Supported Platforms"
    end

    trait :contributing_file do
      name "Contributing File"
    end

    trait :testing_file do
      name "Testing File"
    end

    factory :foodcritic_metric, traits: [:foodcritic]
    factory :collaborator_num_metric, traits: [:collaborator_num]
    factory :publish_metric, traits: [:publish]
    factory :license_metric, traits: [:license]
    factory :supported_platforms_metric, traits: [:supported_platforms]
    factory :contributing_file_metric, traits: [:contributing_file]
    factory :testing_file_metric, traits: [:testing_file]
  end
end
