module MarkdownHelper
  #
  # Make auto-links target=_blank
  #
  class SupermarketRenderer < Redcarpet::Render::HTML
    include ActionView::Helpers::TagHelper

    def initialize(extensions = {})
      super extensions.merge(
        link_attributes: { target: '_blank' },
        with_toc_data: true,
        escape_html: true
      )
    end

    #
    # Create an image tag with a protocol-relative URL
    #
    # @param url [String] the image URL
    # @param title [String, nil] the image title
    # @param alt [String, nil] the image's alternative text
    #
    # @return [String] an image tag
    #
    def image(url, title, alt)
      options = {
        src: relative_url = url.sub(/\Ahttps?:/, ''),
        alt: String(alt),
        title: title
      }

      tag(:img, options, true)
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
