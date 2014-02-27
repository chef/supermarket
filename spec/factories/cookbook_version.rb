FactoryGirl.define do
  factory :cookbook_version do
    association :cookbook

    description "An awesome cookbook!"
    license "MIT"
    version "1.2.0"
    file_url '/tarballs/original/missing.png'
    file_size '10KB'
  end
end
