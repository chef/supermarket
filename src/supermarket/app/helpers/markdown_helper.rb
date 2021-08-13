module MarkdownHelper
  #
  # Make auto-links target=_blank
  #

  class SupermarketRenderer < Redcarpet::Render::Safe
    include ActionView::Helpers::TagHelper

    def initialize(extensions = {})
      super extensions.merge(
        link_attributes: { target: "_blank", rel: "noopener" },
        with_toc_data: true,
        hard_wrap: true,
        xhtml: true
      )
    end

    # Syntax highlighting using CodeRay library
    def block_code(code, language)
      if language.present?
        CodeRay.scan(code, language).div
      else
        "<pre><code>#{code}</code></pre>"
      end
    end

    # process doc to remove markdown comments as it's not supported by RedCarpet
    def remove_comments(raw_html)
      raw_html.gsub(/&lt;!--(.*?)--&gt;/, "")
    end

    #
    # Last stop opportunity to transform the HTML Redcarpet has generated
    # from markdown input.
    #
    # @param html_document [String] the Redcarpet rendered markdown-to-HTML
    #
    # @return [String] HTML document fragrant ready for display
    #
    def postprocess(html_document)
      # if more transforms are added here, some sort of proper pipeline
      # should be considered
      doc = Nokogiri::HTML::DocumentFragment.parse(html_document)
      doc = make_img_src_urls_protocol_relative(doc)
      remove_comments(doc.to_s)
    end

    private

    #
    # Transform generated image tags to use protocol-relative URL
    #
    # @param doc [Nokogiri::HTML::DocumentFragment] already-parsed HTML
    #
    # @return [Nokogiri::HTML::DocumentFragment] transformed, parsed HTML
    #
    def make_img_src_urls_protocol_relative(doc)
      doc.search("img").each do |img|
        next if img["src"].nil?

        src = img["src"].strip
        if src.start_with? "http"
          img["src"] = src.sub!(/\Ahttps?:/, "")
        end
      end

      doc
    end
  end

  #
  # Renders markdown as escaped HTML.
  #
  # @param text [String] markdown to be rendered
  #
  # @return [String] escaped HTML.
  #
  def render_markdown(text)
    Redcarpet::Markdown.new(
      SupermarketRenderer,
      autolink: true,
      fenced_code_blocks: true,
      tables: true,
      no_intra_emphasis: true,
      strikethrough: true,
      superscript: true
    ).render(
      text
    ).html_safe # rubocop:todo Rails/OutputSafety
  end
end