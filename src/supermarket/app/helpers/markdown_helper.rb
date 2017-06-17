require 'html/pipeline'

module MarkdownHelper
  #
  # Renders markdown as escaped HTML.
  #
  # @param text [String] markdown to be rendered
  #
  # @return [String] escaped HTML.
  #
  def render_markdown(text)
    context = {
      base_url: Supermarket::Host.full_url,
      http_url: Supermarket::Host.full_url
    }

    pipeline = HTML::Pipeline.new [
      HTML::Pipeline::MarkdownFilter,
      HTML::Pipeline::SanitizationFilter,
      HTML::Pipeline::ImageMaxWidthFilter,
      HTML::Pipeline::HttpsFilter,
      HTML::Pipeline::MentionFilter
    ], context.merge(gfm: true)

    result = pipeline.call(text)
    result[:output].to_s.html_safe
  end
end
