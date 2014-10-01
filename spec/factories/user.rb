FactoryGirl.define do
  factory :user do
    first_name 'John'
    last_name 'Doe'
    public_key { File.read('spec/support/key_fixtures/valid_public_key.pub') }
    email_preferences [:new_version, :deleted, :deprecated]

    sequence(:email) { |n| "johndoe#{n}@example.com" }

    ignore do
      create_chef_account true
    end

    after(:create) do |user, evaluator|
      if evaluator.create_chef_account
        create(:account, provider: 'chef_oauth2', user: user)
      end
    end

    factory :admin, class: User do
      first_name 'Admin'
      last_name 'User'
      roles_mask 1
    end
  end
end
