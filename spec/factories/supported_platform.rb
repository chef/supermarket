FactoryGirl.define do
  factory :supported_platform do
    association :cookbook_version

    name 'ubuntu'
    version_constraint '>= 12.04'
  end
end
