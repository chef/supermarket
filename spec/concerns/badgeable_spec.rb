require 'spec_helper.rb'

class BadgeableThing
  include Badgeable
  attr_accessor :badges_mask
end

shared_examples 'a badgeable thing' do
  it 'has a badges_mask to remember badges assigned' do
    expect(subject).to respond_to(:badges_mask)
  end

  context 'has badgeable methods' do
    badgeable_methods = BadgeableThing.new.methods - Object.methods

    badgeable_methods.each do |method|
      it { should respond_to(method)}
    end
  end

  it 'can have badges set' do
    subject.badges = :partner
    expect(subject.badges).to eq(['partner'])
  end

  it 'does not allow invalid badges' do
    subject.badges = [:noper_mcnoperson, :partner]
    expect(subject.badges).to eq(['partner'])
  end

  it 'answers identityish questions about a thing having a badge' do
    subject.badges = :partner
    expect(subject.is? :partner).to eq(true)
  end

  it 'answers whether it has all of a given set of badges (really pending more badges being added)' do
    subject.badges = :partner
    expect(subject.all? :partner).to eq(true)
  end
end

describe Badgeable do
  describe 'the badges order matters so' do
    subject { Badgeable::BADGES }
    it 'partner is first' do
      expect(subject[0]).to eq('partner')
    end
  end

  describe BadgeableThing do
    it_behaves_like 'a badgeable thing'
  end
end
