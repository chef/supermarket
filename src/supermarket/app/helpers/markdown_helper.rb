module MarkdownHelper
  #
  # Make auto-links target=_blank
  #
  class SupermarketRenderer < Redcarpet::Render::Safe
    include ActionView::Helpers::TagHelper

    def initialize(extensions = {})
      super extensions.merge(
        link_attributes: { target: '_blank' },
        with_toc_data: true
      )
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
      doc.to_s
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
        next if img['src'].nil?
        src = img['src'].strip
        if src.start_with? 'http'
          img["src"] = src.sub!(/\Ahttps?:/, '')
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
    ).html_safe
  end
end
