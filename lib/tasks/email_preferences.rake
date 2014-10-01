namespace :email_preferences do
  task migrate: :environment do
    User.where(email_notifications: true).find_each do |user|
      user.email_preferences << :new_version
      user.save
    end
  end
end
