require 'spec_helper'

describe MarkdownHelper do
  describe '#render_markdown' do
    it 'renders markdown' do
      expect(helper.render_markdown('# Test')).to match(/h1/)
    end

    it 'renders fenced code blocks' do
      codeblock = <<-CODEBLOCK.strip_heredoc
        ```sh
        $ bundle exec rake spec:all
        ```
      CODEBLOCK

      expect(helper.render_markdown(codeblock)).to match(/<pre><code>/)
    end

    it 'auto renders links with target blank' do
      expect(helper.render_markdown('http://chef.io')).
        to match(Regexp.quote('<a href="http://chef.io" target="_blank">http://chef.io</a>'))
    end
  end

  it 'renders tables' do
    table = <<-TABLE.strip_heredoc
      | name | version |
      | ---- | ------- |
      | apt  | 0.25    |
      | yum  | 0.75    |
    TABLE

    expect(helper.render_markdown(table)).to match(/<table>/)
  end

  it "adds br tags on hard wraps" do
    markdown = <<~HARDWRAP.strip_heredoc
      There is a hard
      wrap.
    HARDWRAP

    expect(helper.render_markdown(markdown)).to match(/<br>/)
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

  context 'protocol in URLs for images get converted' do
    it 'HTTP -> protocol-relative' do
      html = helper.render_markdown('![](http://img.example.com)')
      expect(html).to include('<img src="//img.example.com" alt="">')
    end

    it 'HTTPS -> protocol-relative' do
      html = helper.render_markdown('![](https://img.example.com)')
      expect(html).to include('<img src="//img.example.com" alt="">')
    end
  end

  describe 'to prevent XSS attacks' do
    # most of these payloads were found at the very helpful
    # https://github.com/cujanovic/Markdown-XSS-Payloads

    it 'escapes bare-html iframes' do
      html = helper.render_markdown("<iframe src=javascript:alert('hahaha')></iframe>")
      expect(html).to include("<p>&lt;iframe")
    end

    it 'renders only one link when there is a link within a link' do
      html = helper.render_markdown('[text](http://example.com " [@chef](/cheffery) ")')
      expect(html).to include("<p><a href=\"http://example.com\" title=\" [@chef](/cheffery) \" target=\"_blank\">text</a></p>")
    end

    payloads = <<~PAYLOADS
      javascript:prompt(document.cookie)
      j    a   v   a   s   c   r   i   p   t:prompt(document.cookie)
      &#x6A&#x61&#x76&#x61&#x73&#x63&#x72&#x69&#x70&#x74&#x3A&#x61&#x6C&#x65&#x72&#x74&#x28&#x27&#x58&#x53&#x53&#x27&#x29
      javascript:window.onerror=alert;throw%20document.cookie
      javascript://%0d%0awindow.onerror=alert;throw%20document.cookie
      javascript://%0d%0aprompt(1)
      javascript://%0d%0aprompt(1);com
      javascript:window.onerror=alert;throw%20document.cookie
      javascript://%0d%0awindow.onerror=alert;throw%20document.cookie
      data:text/html;base64,PHNjcmlwdD5hbGVydCgnWFNTJyk8L3NjcmlwdD4K
      vbscript:alert(document.domain)
      javascript:this;alert(1)
      javascript:this;alert(1&#41;
      javascript&#58this;alert(1&#41;
      Javas&#99;ript:alert(1&#41;
      Javas%26%2399;ript:alert(1&#41;
      javascript:alert&#65534;(1&#41;
      javascript:confirm(1
      javascript://%0d%0aconfirm(1);com
      javascript:window.onerror=confirm;throw%201
      javascript:alert(document.domain&#41;
    PAYLOADS

    describe "does not render an HTML anchor for" do
      payloads.split("\n").each do |payload|
        it "[link text](#{payload})" do
          expect(helper.render_markdown("[a](#{payload})")).not_to match(/<a href/)
        end
      end
    end

    describe "does not render an HTML img tag for" do
      payloads.split("\n").each do |payload|
        it "![img alt text](#{payload})" do
          expect(helper.render_markdown("![a](#{payload})")).not_to match(/<img src/)
        end
      end

      it "funky alt text" do
        html = helper.render_markdown(%q{![alt text'"`onerror=prompt(document.cookie)](x)})
        expect(html).not_to match(/<img src/)
      end
    end

    describe "with miscellaneous payloads" do
      it "escapes bracketed javascript" do
        html = helper.render_markdown("<javascript:prompt(document.cookie)>")
        expect(html).to include("<p>&lt;javascript:prompt(document.cookie)&gt;</p>")
      end

      it "escapes unicode shenanigans" do
        html = helper.render_markdown("<&#x6A&#x61&#x76&#x61&#x73&#x63&#x72&#x69&#x70&#x74&#x3A&#x61&#x6C&#x65&#x72&#x74&#x28&#x27&#x58&#x53&#x53&#x27&#x29>")
        expect(html).to include("<p>&lt;&amp;#x6A&amp;#x61&amp;#x76&amp;#x61&amp;#x73&amp;#x63&amp;#x72&amp;#x69&amp;#x70&amp;#x74&amp;#x3A&amp;#x61&amp;#x6C&amp;#x65&amp;#x72&amp;#x74&amp;#x28&amp;#x27&amp;#x58&amp;#x53&amp;#x53&amp;#x27&amp;#x29&gt;</p>")
      end

      it "does not link with a javascript: scheme even though a URL is detected" do
        html = helper.render_markdown("[link text](javascript://www.google.com%0Aprompt(1))")
        expect(html).to include('<p>[link text](javascript://<a href="http://www.google.com%0Aprompt(1)"')
      end

      it "dodges footnote shenanigans by not parsing citations into links" do
        payload = <<~CITATION
          This is funny.[^lol]

          [^lol]: (javascript:prompt(document.cookie))
        CITATION

        html = helper.render_markdown(payload)
        # this expectation is based on the markdown transformer configured
        # to NOT parse citations/footnotes
        expect(html).not_to match(/<a href/)
      end

      it "prevents URL & email detection combining with emphasis, does not put base64 shenanigans into the link" do
        payload = "_http://example_@.1 style=background-image:url(data:image/png;base64,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);background-repeat:no-repeat;display:block;width:100%;height:100px; onclick=alert(unescape(/Oh%20No!/.source));return(false);//"
        html = helper.render_markdown(payload)
        expect(html).to include('<p><em><a href="http://example" target="_blank">http://example</a></em>@.1 style=background-image:url(data:image/png;base64,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);background-repeat:no-repeat;display:block;width:100%;height:100px; onclick=alert(unescape(/Oh%20No!/.source));return(false);//</p>')
      end

      it "escapes brackets to prevent meta tag manipulation" do
        payload = '<http://\<meta\ http-equiv=\"refresh\"\ content=\"0;\ url=http://example.com/\"\>>'
        html = helper.render_markdown(payload)
        # note URL detection will see a URL and create a link for it within this payload
        # but the auto refresh/redirect to it is prevented
        expect(html).to include('<p>&lt;http://&lt;meta')
      end
    end
  end
end
