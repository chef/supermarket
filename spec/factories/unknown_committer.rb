FactoryGirl.define do
  factory :unknown_committer, class: Curry::UnknownCommitter do
    email nil
    login nil
  end
end
