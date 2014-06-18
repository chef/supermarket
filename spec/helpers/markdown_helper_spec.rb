require 'spec_helper'

describe MarkdownHelper do
  describe '#render_markdown' do
    it 'renders markdown' do
      expect(helper.render_markdown('# Test')).to eq("<h1>Test</h1>\n")
    end

    it 'renders fenced code blocks' do
      codeblock = <<-EOH
```sh
$ bundle exec rake spec:all
```
      EOH

      expect(helper.render_markdown(codeblock)).to match(/<pre><code class="sh">/)
    end

    it 'auto renders links with target blank' do
      expect(helper.render_markdown('http://getchef.com')).
        to match(Regexp.quote('<a href="http://getchef.com" target="_blank">http://getchef.com</a>'))
    end
  end

  it 'renders tables' do
    table = <<-EOH
| name | version |
| ---- | ------- |
| apt  | 0.25    |
| yum  | 0.75    |
    EOH

    expect(helper.render_markdown(table)).to match(/<table>/)
  end
end
