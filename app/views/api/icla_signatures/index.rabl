collection @icla_signatures

attribute :id
attribute :signed_at

child :user do
  attribute :name
end
