require 'spec_helper'

describe Account do
  context 'associations' do
    it { should belong_to(:user) }
  end

  context 'validations' do
    it { should validate_presence_of(:user) }
    it { should validate_presence_of(:uid) }
    it { should validate_presence_of(:provider) }
  end

  describe '.for' do
    let!(:githubs) { create_list(:account, 2, provider: 'github') }
    let!(:twitters) { create_list(:account, 3, provider: 'twitter') }

    it 'returns an empty array when there are no accounts' do
      expect(Account.for(:non_existent)).to be_empty
    end

    it 'returns the correct accounts' do
      expect(Account.for(:github)).to eq(githubs)
      expect(Account.for(:twitter)).to eq(twitters)
    end
  end
end
