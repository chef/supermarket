object @user

attribute :id
attribute :prefix
attribute :first_name
attribute :middle_name
attribute :last_name
attribute :suffix
attribute :signed_icla? => :signed_icla

node :primary_email do |user|
  user.primary_email.try(:email)
end

node :phone do |user|
  number_to_phone(user.phone)
end

child :accounts do
  attribute :uid
end

child :emails do
  attribute :email
  attribute :confirmed? => :confirmed
end
