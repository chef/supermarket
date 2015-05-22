namespace :user do

  # Usage: rake user:make_admin user="#{username of user to be made an admin}"
  desc "Take a username, find the user, and make that user an admin"
  task :make_admin => :environment do
    make_admin_user = MakeUserAdmin.new(ENV['user']).call
    puts make_admin_user
  end
end
