namespace :email_preferences do
  task migrate: :environment do
    User.where(email_notifications: true).find_each do |user|
      EmailPreference.default_set_for_user(user)
      user.update_attribute(:email_notifications, false)
    end
  end
end
