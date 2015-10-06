require 'spec_helper'

describe IclaSignature do
  context 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:icla) }
  end

  context 'validations' do
    it { should validate_presence_of(:user) }
    it { should validate_presence_of(:user) }
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:phone) }
    it { should validate_presence_of(:address_line_1) }
    it { should validate_presence_of(:city) }
    it { should validate_presence_of(:state) }
    it { should validate_presence_of(:zip) }
    it { should validate_presence_of(:country) }
    it { should validate_acceptance_of(:agreement) }
  end

  context 'callbacks' do
    it 'sets the value of signed_at' do
      time = Time.at(680_241_600)
      allow(Time).to receive(:now).and_return(time)

      icla_signature = create(:icla_signature)
      expect(icla_signature.signed_at).to eq(time)
    end
  end

  describe '.by_user' do
    context 'when multiple users have signed an ICLA' do
      let(:user_one) { create(:user) }
      let(:user_two) { create(:user) }
      let!(:user_two_signature) { create(:icla_signature, user: user_two, signed_at: 1.day.ago) }
      let!(:user_one_signature) { create(:icla_signature, user: user_one, signed_at: 1.year.ago) }

      it 'should return the signatures' do
        expect(IclaSignature.by_user.count).to eql(2)
      end

      it 'should order the signatures ascending by signed at date' do
        expect(IclaSignature.by_user.first).to eql(user_one_signature)
      end

      it 'eager loads the associated users and their associated accounts' do
        signatures = IclaSignature.by_user.to_a
        signature = signatures.first

        user = User.find(signature.user_id)
        account = user.accounts.first

        user.destroy
        account.destroy

        expect(signatures.map(&:user)).to include(user)
        expect(signatures.map(&:user).flat_map(&:accounts)).to include(account)
      end
    end

    context 'when a user has re-signed an ICLA' do
      let(:user) { create(:user) }
      let!(:one_day_ago) { create(:icla_signature, user: user, signed_at: 1.day.ago) }
      let!(:one_year_ago) { create(:icla_signature, user: user, signed_at: 1.year.ago) }

      it 'should return the latest signature' do
        expect(IclaSignature.by_user).to include(one_day_ago)
      end

      it 'should not return older signatures' do
        expect(IclaSignature.by_user).to_not include(one_year_ago)
      end
    end
  end
end
