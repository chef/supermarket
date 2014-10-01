require 'spec_helper'

describe UnsubscribeRequest do
  context 'associations' do
    it { should belong_to(:user) }
  end

  context 'validations' do
    it { should validate_presence_of(:user) }
    it { should validate_presence_of(:email_preference_name) }
  end

  it 'should unsubscribe users from emails' do
    user = create(:user)

    [:new_version, :deleted, :deprecated].each do |name|
      expect(user.email_preferences?(name)).to eql(true)
      ur = create(:unsubscribe_request, user: user, email_preference_name: name)
      ur.make_it_so
      expect(user.reload.email_preferences?(name)).to eql(false)
      expect do
        UnsubscribeRequest.find(ur.id)
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  it 'should have a token by default' do
    ur = build(:unsubscribe_request)
    expect(ur).to be_valid
    expect(ur.token).to be_present
  end

  it 'should delete all UnsubscribeRequests for the same email and user' do
    hank = create(:user)
    sally = create(:user)
    ur = create(:unsubscribe_request, user: hank, email_preference_name: 'new_version')
    create(:unsubscribe_request, user: hank, email_preference_name: 'new_version')
    create(:unsubscribe_request, user: hank, email_preference_name: 'deleted')
    create(:unsubscribe_request, user: sally, email_preference_name: 'new_version')

    expect do
      ur.make_it_so
    end.to change(UnsubscribeRequest, :count).by(-2)
  end
end
