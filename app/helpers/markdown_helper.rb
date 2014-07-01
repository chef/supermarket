module MarkdownHelper
  #
  # Make auto-links target=_blank
  #
  class SupermarketRenderer < Redcarpet::Render::HTML
    def initialize(extensions = {})
      super extensions.merge(link_attributes: { target: '_blank' }, with_toc_data: true, hard_wrap: true)
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
