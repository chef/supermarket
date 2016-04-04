require 'spec_helper.rb'

describe Badgeable do
  describe 'the badges order matters so' do
    subject { Badgeable::BADGES }
    it 'partner is first' do
      expect(subject[0]).to eq('partner')
    end
  end

  # from spec/support/shared_examples/badgeable_shared.rb
  describe BadgeableThing do
    it_behaves_like 'a badgeable thing'
  end
end
