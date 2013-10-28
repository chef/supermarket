object @icla_signature

attribute :id
attribute :signed_at

child :user do
  attribute :id
  attribute :name

  node :link do |user|
    api_user_url(user)
  end
end
