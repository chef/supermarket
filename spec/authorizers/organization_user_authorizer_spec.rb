require 'isolated_spec_helper'
require 'organization_user_authorizer'

describe OrganizationUserAuthorizer do

  describe '#destroy?' do

    it 'does not allow non-admin contributors to delete contributors' do
      user = double('User')
      contributor = double('OrganizationUser')

      allow(contributor).to receive(:organization)
      allow(user).to receive(:is_admin_of_organization?) { false }

      authorizer = OrganizationUserAuthorizer.new(user, contributor)
      expect(authorizer.destroy?).to be_false
    end

    it 'allows admin contributors to delete other admin contributors in the organization' do
      user = double('User')
      contributor = double('OrganizationUser')

      allow(contributor).to receive(:organization)
      allow(contributor).to receive(:admin?) { true }
      allow(contributor).to receive(:only_admin?) { false }

      allow(user).to receive(:is_admin_of_organization?) { true }

      authorizer = OrganizationUserAuthorizer.new(user, contributor)
      expect(authorizer.destroy?).to be_true
    end

    it 'allows admin contributors to delete non-admin contributors in the organization' do
      user = double('User')
      contributor = double('OrganizationUser')

      allow(contributor).to receive(:organization)
      allow(contributor).to receive(:admin?) { false }

      allow(user).to receive(:is_admin_of_organization?) { true }

      authorizer = OrganizationUserAuthorizer.new(user, contributor)
      expect(authorizer.destroy?).to be_true
    end

    it 'does not allow admins to delete the last remaining admin (themself)' do
      user = double('User')
      contributor = double('OrganizationUser')

      allow(contributor).to receive(:organization)
      allow(contributor).to receive(:admin?) { true }
      allow(contributor).to receive(:only_admin?) { true }

      allow(user).to receive(:is_admin_of_organization?) { true }

      authorizer = OrganizationUserAuthorizer.new(user, contributor)
      expect(authorizer.destroy?).to be_false
    end

  end

end
