FactoryGirl.define do
  factory :supported_platform do
    name 'ubuntu'
    version_constraint '>= 12.04'
  end
end
