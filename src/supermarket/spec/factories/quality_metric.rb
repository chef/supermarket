FactoryBot.define do
  factory :quality_metric, class: "QualityMetric" do

    trait :collaborator_num do
      name { "Collaborator Number" }
    end

    trait :license do
      name { "License" }
    end

    trait :contributing_file do
      name { "Contributing File" }
    end

    trait :testing_file do
      name { "Testing File" }
    end

    trait :version_tag do
      name { "Version Tag" }
    end

    trait :no_binaries do
      name { "No Binaries" }
    end

    trait :cookstyle do
      name { "Cookstyle" }
    end

    factory :collaborator_num_metric, traits: [:collaborator_num]
    factory :license_metric, traits: [:license]
    factory :contributing_file_metric, traits: [:contributing_file]
    factory :testing_file_metric, traits: [:testing_file]
    factory :version_tag_metric, traits: [:version_tag]
    factory :no_binaries_metric, traits: [:no_binaries]
    factory :cookstyle_metric, traits: [:cookstyle]
  end
end
