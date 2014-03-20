require 'spec_helper'

describe MarkdownHelper do
  describe '#render_markdown' do
    it 'renders markdown' do
      expect(helper.render_markdown('# Test')).to eq("<h1>Test</h1>\n")
    end
  end
end
