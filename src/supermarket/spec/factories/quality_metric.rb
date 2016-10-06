FactoryGirl.define do
  factory :quality_metric, class: 'QualityMetric' do
    trait :foodcritic do
      name "Foodcritic"
    end

    trait :collaborator_num do
      name "Collaborator Number"
    end

    factory :foodcritic_metric, traits: [:foodcritic]
    factory :collaborator_num_metric, traits: [:collaborator_num]
  end
end
