require 'spec_helper'

describe EmailPreference do
  context 'associations' do
    it { should belong_to(:system_email) }
    it { should belong_to(:user) }
  end

  context 'validations' do
    it { should validate_presence_of(:user) }
    it { should validate_presence_of(:system_email) }
  end

  it 'should have a token by default' do
    ep = build(:email_preference)
    expect(ep).to be_valid
    expect(ep.token).to be_present
  end

  it 'should provide a default set of email preferences for a user' do
    create(:system_email, name: 'lol')
    create(:system_email, name: 'wut')
    create(:system_email, name: 'yiss')

    hank = create(:user)
    hank.reload
    expect(hank.email_preferences.size).to eql(3)
    expect(hank.system_emails.map(&:name)).to include('lol', 'wut', 'yiss')
  end
end
