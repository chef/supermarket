module MarkdownHelper
  #
  # Make auto-links target=_blank
  #
  class TargetBlankRenderer < Redcarpet::Render::HTML
    def initialize(extensions = {})
      super extensions.merge(link_attributes: { target: '_blank' })
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
      TargetBlankRenderer,
      autolink: true,
      fenced_code_blocks: true,
      tables: true
    ).render(
      text
    ).html_safe
  end
end
