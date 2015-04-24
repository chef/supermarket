require 'spec_helper'

describe MarkdownHelper do
  describe '#render_markdown' do
    it 'renders markdown' do
      expect(helper.render_markdown('# Test')).to match(/h1/)
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
      expect(helper.render_markdown('http://chef.io')).
        to match(Regexp.quote('<a href="http://chef.io" target="_blank">http://chef.io</a>'))
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

  it "doesn't adds br tags on hard wraps" do
    markdown = <<-EOH
There is no hard
wrap.
    EOH

    expect(helper.render_markdown(markdown)).to_not match(/<br>/)
  end

  it "doesn't emphasize underscored words" do
    expect(helper.render_markdown('some_long_method_name')).to_not match(/<em>/)
  end

  it 'adds HTML anchors to headers' do
    expect(helper.render_markdown('# Tests')).to match(/id="tests"/)
  end

  it 'strikesthrough text using ~~ with a del tag' do
    expect(helper.render_markdown('~~Ignore This~~')).to match(/<del>/)
  end

  it 'superscripts text using ^ with a sup tag' do
    expect(helper.render_markdown('Supermarket^2')).to match(/<sup>/)
  end

  it 'uses protocol-relative URLs for images served over HTTP' do
    html = helper.render_markdown('![](http://img.example.com)')

    expect(html).to include('<img alt="" src="//img.example.com">')
  end

  it 'prevents XSS attacks' do
    html = helper.render_markdown("<iframe src=javascript:alert('hahaha')></iframe>")
    expect(html).to match(/&lt;iframe src=javascript:alert\(&#39;hahaha&#39;\)&gt;&lt;\/iframe&gt;/)
  end

  it 'uses protocol-relative URLs for images served over HTTPS' do
    html = helper.render_markdown('![](https://img.example.com)')

    expect(html).to include('<img alt="" src="//img.example.com">')
  end

  it 'escapes attribute values' do
    html = helper.render_markdown('!["><"]("><" "><")')
    attribute = '&quot;&gt;&lt;&quot;'

    escaped_html = %(
      <img alt="#{attribute}" src="#{attribute}" title="&gt;&lt;">
    ).squish

    expect(html).to include(escaped_html)
  end
end
