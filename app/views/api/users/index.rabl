collection @users

attribute :id
attribute :name
node(:link) { |user| api_user_url(user) }
