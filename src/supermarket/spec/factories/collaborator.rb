FactoryBot.define do
  factory :cookbook_collaborator, class: "Collaborator" do
    association :resourceable, factory: :cookbook
    association :user
  end

  factory :tool_collaborator, class: "Collaborator" do
    association :resourceable, factory: :tool
    association :user
  end
end
