module CclaSignaturesHelper
  #
  # Generates the HTML for a tab in the organization partial, with conditional
  # logic to make it active if it's the current page.
  #
  # @param txt [String] the text for the link
  # @param path [String] the path for the link
  #
  # @return [String] HTML representing a tab
  #
  def organization_tab(txt, path)
    cls = current_page?(path) ? 'active' : nil
    content_tag :dd, class: cls do
      link_to txt, path
    end
  end
end
