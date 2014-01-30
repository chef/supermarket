FactoryGirl.define do
  factory :pull_request, class: Curry::PullRequest do
    association :repository
    number      '1'
  end
end
