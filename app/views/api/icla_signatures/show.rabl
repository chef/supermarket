object @icla_signature

attribute :id
attribute :signed_at

child :user do
  attribute :id
  attribute :name

  node :link do |user|
    user_url(user)
  end
end
