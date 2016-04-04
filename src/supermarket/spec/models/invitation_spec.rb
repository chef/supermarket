require 'spec_helper'

describe Invitation do
  describe '.with_token!' do
    it 'returns the invitation which has the given token' do
      existing_invitation = create(:invitation)
      token = existing_invitation.token

      expect(Invitation.with_token!(token)).to eql(existing_invitation)
    end

    it 'raises ActiveRecord::RecordNotFound when an invitation cannot be found' do
      expect do
        Invitation.with_token!('')
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
