collection @users

attribute :id
attribute :name
node(:link) { |user| user_url(user) }
