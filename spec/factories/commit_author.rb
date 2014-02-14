FactoryGirl.define do
  factory :commit_author, class: Curry::CommitAuthor do
    email nil
    login nil
    signed_cla false
  end
end
