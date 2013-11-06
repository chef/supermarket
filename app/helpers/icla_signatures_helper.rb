module IclaSignaturesHelper
  # Render markdown
  def markdown(text = '')
    Redcarpet::Markdown.new(Redcarpet::Render::HTML).render(text).html_safe
  end
end
