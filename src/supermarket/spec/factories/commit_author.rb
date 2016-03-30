FactoryGirl.define do
  factory :commit_author, class: Curry::CommitAuthor do
    email nil
    login nil
    authorized_to_contribute false
  end
end
