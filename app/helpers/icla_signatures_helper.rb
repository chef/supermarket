module IclaSignaturesHelper
  # Make auto-links target=_blank
  class TargetBlankRenderer < Redcarpet::Render::HTML
    def initialize(extensions = {})
      super extensions.merge(link_attributes: { target: "_blank" })
    end
  end

  # Render markdown
  def markdown(text = '')
    Redcarpet::Markdown.new(TargetBlankRenderer, :autolink => true).render(text).html_safe
  end
end
