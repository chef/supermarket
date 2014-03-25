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

  #
  # Returns a span that displays a tooltip for the cookbook version, showing
  # last updated at and download count.
  #
  # @param version [CookbookVersion] the cookbook version
  #
  # @return [String] the span tag with the appropriate information
  #
  # @yieldreturn [String] the tooltip enabled content
  #
  def tooltip_for(version)
    updated_at = version.updated_at.to_s(:db)
    download_count = version.download_count

    content_tag(
      :span,
      data: { tooltip: true },
      class: 'has-tip',
      title: "Updated at: #{updated_at}. Downloaded #{download_count} times."
    ) do
      yield
    end
  end
end
