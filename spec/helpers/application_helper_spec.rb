require 'spec_helper'

describe ApplicationHelper do
  describe '#auth_path' do
    context 'when using a symbol' do
      it 'returns the correct path' do
        expect(auth_path(:github)).to eq('/auth/github')
      end
    end

    context 'when using a string' do
      it 'returns the correct path' do
        expect(auth_path('github')).to eq('/auth/github')
      end
    end
  end

  describe '#posessivize' do
    it "should end in 's if the name does not end in s" do
      expect(posessivize('Black')).to eql "Black's"
    end

    it "should end in ' if the name ends in s" do
      expect(posessivize('Volkens')).to eql "Volkens'"
    end

    it 'should return an empty string when passed one' do
      expect(posessivize('')).to eql ''
    end

    it 'should return nil when passed nil' do
      expect(posessivize(nil)).to be_nil
    end
  end
end
