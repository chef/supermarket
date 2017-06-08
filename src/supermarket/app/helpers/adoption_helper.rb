module AdoptionHelper
  #
  # Return a link to either a Cookbook or a Tool to enable/disable adoption.
  #
  # @param obj [Cookbook,Tool]
  #
  # @return [String] the link, wrapped in an <li>
  #
  def link_to_adoption(obj)
    if policy(obj).manage_adoption?
      txt, up = if obj.up_for_adoption?
                  ['Disable adoption', false]
                else
                  ['Put up for adoption', true]
                end

      content_tag(:li, adoption_url(obj, txt, up))
    end
  end

  private

  #
  # The actual URL to use in link_to_adoption. This will work for both
  # Cookbooks and Tools.
  #
  # @param obj [Cookbook,Tool] The Cookbook or Tool to link to
  # @param txt [String] The text of the URL
  # @param up [Boolean] This will be True or False, depending on if adoption is
  # being enabled or disabled.
  #
  # @return [String] the URL to link to
  #
  def adoption_url(obj, txt, up)
    link_to(polymorphic_path(obj, obj.class.name.downcase => { up_for_adoption: up }), method: :patch, data: { confirm: "Are you sure you want to put this up for adoption?" }) do
      "<i class=\"fa fa-heart\"></i> #{txt}".html_safe
    end
  end
end
