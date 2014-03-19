module CookbookVersionsHelper
  include MarkdownHelper

  #
  # Returns the given README +content+ as it should be rendered. If the given
  # +extension+ indicates the README is formatted as Markdown, the +content+ is
  # parsed as such.
  #
  # @param content [String] the README content
  # @param extension [String] the README extension
  #
  # @return [String] the README content ready to be rendered
  #
  def render_readme(content, extension)
    if %w(md mdown markdown).include?(extension.downcase)
      render_markdown(content)
    else
      content
    end
  end
end
