module CookbookVersionsHelper
  include MarkdownHelper

  def render_readme(content, extension)
    if %w(md mdown markdown).include?(extension.downcase)
      render_markdown(content)
    else
      content
    end
  end
end
