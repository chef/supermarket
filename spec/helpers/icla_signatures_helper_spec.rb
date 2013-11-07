require 'spec_helper'

describe IclaSignaturesHelper do
  describe '#markdown' do
    it 'renders markdown' do
      expect(helper.markdown('# Test')).to eq("<h1>Test</h1>\n")
    end
  end
end
