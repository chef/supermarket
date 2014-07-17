require 'spec_helper'

describe ContributorRequest do
  context 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:ccla_signature) }
    it { should belong_to(:organization) }
  end

  context 'validations' do
    it { should validate_presence_of(:user) }
    it { should validate_presence_of(:ccla_signature) }
    it { should validate_presence_of(:organization) }
  end

  describe '#presiding_admins' do
    it 'is the collection of Users who are admins of the requested Organization' do
      admin_users = 2.times.map { create(:user) }
      other_admin_user = create(:user)

      desired_organization = Organization.create!
      other_organization = Organization.create!

      admin_users.each do |admin_user|
        desired_organization.admins.create!(user: admin_user)
      end

      other_organization.admins.create!(user: other_admin_user)

      ccla_signature = create(
        :ccla_signature,
        user: admin_users.first,
        organization: desired_organization
      )

      contributor_request = ContributorRequest.create!(
        user: create(:user),
        organization: desired_organization,
        ccla_signature: ccla_signature
      )

      expect(contributor_request.presiding_admins).to match_array(admin_users)
      expect(contributor_request.presiding_admins).
        to_not include(other_admin_user)
    end
  end
end
