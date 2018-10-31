FactoryBot.define do
  factory :cookbook_version_platform do
    association :cookbook_version
    association :supported_platform
  end
end
