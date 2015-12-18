FactoryGirl.define do
  factory :group_member do
    association :user
    association :group
    admin nil

    factory :admin_group_member, class: GroupMember do
      admin true
    end
  end
end
