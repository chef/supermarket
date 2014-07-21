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

  describe '#pending?' do
    it 'is true when there are no responses to the request' do
      contributor_request = create(:contributor_request)

      expect(contributor_request).to be_pending
    end

    it 'is false when the request has been accepted' do
      contributor_request = create(:contributor_request)
      contributor_request.accept

      expect(contributor_request).to_not be_pending
    end

    it 'is false when the request has been declined' do
      contributor_request = create(:contributor_request)
      contributor_request.decline

      expect(contributor_request).to_not be_pending
    end
  end

  describe '#accepted?' do
    it 'is false when there are no responses to the request' do
      contributor_request = create(:contributor_request)

      expect(contributor_request).to_not be_accepted
    end

    it 'is true when the request has been accepted' do
      contributor_request = create(:contributor_request)
      contributor_request.accept

      expect(contributor_request).to be_accepted
    end

    it 'is false when the request has been declined' do
      contributor_request = create(:contributor_request)
      contributor_request.decline

      expect(contributor_request).to_not be_accepted
    end
  end

  describe '#declined?' do
    it 'is false when there are no responses to the request' do
      contributor_request = create(:contributor_request)

      expect(contributor_request).to_not be_declined
    end

    it 'is false when the request has been accepted' do
      contributor_request = create(:contributor_request)
      contributor_request.accept

      expect(contributor_request).to_not be_declined
    end

    it 'is false when the request has been declined' do
      contributor_request = create(:contributor_request)
      contributor_request.decline

      expect(contributor_request).to be_declined
    end
  end

  describe '#accept' do
    it 'does not accept requests which have already been declined' do
      contributor_request = create(:contributor_request)
      contributor_request.decline
      contributor_request.accept

      expect(contributor_request).to be_declined
    end

    it 'adds the user as a contributor to the organization' do
      contributor_request = create(:contributor_request)
      organization = contributor_request.organization
      user = contributor_request.user

      user_contributor = organization.contributors.where(user_id: user.id)

      expect { contributor_request.accept }.
        to change(user_contributor, :count).from(0).to(1)
    end

    it 'yields if the request has not already been accepted or declined' do
      contributor_request = create(:contributor_request)

      expect { |b| contributor_request.accept(&b) }.to yield_with_no_args
    end

    it 'does not yield if the request has already been accepted' do
      contributor_request = create(:contributor_request)
      contributor_request.accept

      expect { |b| contributor_request.accept(&b) }.to_not yield_control
    end

    it 'does not yield if the request has already been declined' do
      contributor_request = create(:contributor_request)
      contributor_request.decline

      expect { |b| contributor_request.accept(&b) }.to_not yield_control
    end
  end

  describe '#decline' do
    it 'does not decline requests which have already been accepted' do
      contributor_request = create(:contributor_request)
      contributor_request.accept
      contributor_request.decline

      expect(contributor_request).to be_accepted
    end

    it 'yields if the request has not already been accepted or declined' do
      contributor_request = create(:contributor_request)

      expect { |b| contributor_request.decline(&b) }.to yield_with_no_args
    end

    it 'does not yield if the request has already been accepted' do
      contributor_request = create(:contributor_request)
      contributor_request.accept

      expect { |b| contributor_request.decline(&b) }.to_not yield_control
    end

    it 'yields true, false if the request has already been declined' do
      contributor_request = create(:contributor_request)
      contributor_request.decline

      expect { |b| contributor_request.decline(&b) }.to_not yield_control
    end
  end
end
