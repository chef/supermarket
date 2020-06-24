FactoryBot.define do
  factory :cookbook_dependency do
    association :cookbook_version
    association :cookbook

    name { "apt" }
    version_constraint { ">= 0.1.0" }
  end
end
