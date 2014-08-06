module CookbookVersionsHelper
  include MarkdownHelper

  #
  # Returns the given README +content+ as it should be rendered. If the given
  # +extension+ indicates the README is formatted as Markdown, the +content+ is
  # rendered as such.
  #
  # @param content [String] the Document content
  # @param extension [String] the Document extension
  #
  # @return [String] the Document content ready to be rendered
  #
  def render_document(content, extension)
    if %w(md mdown markdown).include?(extension.downcase)
      render_markdown(content)
    else
      content
    end
  end
end
