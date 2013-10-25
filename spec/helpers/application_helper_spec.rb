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
end
