module PartnerHelper
  #
  # Return a link to either a Cookbook or a Tool to enable/disable Partner Status.
  #
  # @param obj [Cookbook,Tool]
  #
  # @return [String] the link, wrapped in an <li>
  #
  def link_to_partner_status(obj)
    if policy(obj).manage_partner?
      txt, up = if obj.partner_status?
                  ['Disable Partner', false]
                else
                  ['Enable Partner', true]
                end

      content_tag(:li, partner_url(obj, txt, up))
    end
  end

  private

  #
  # The actual URL to use in link_to_partner_status. This will work for both
  # Cookbooks and Tools.
  #
  # @param obj [Cookbook,Tool] The Cookbook or Tool to link to
  # @param txt [String] The text of the URL
  # @param up [Boolean] This will be True or False, depending on if adoption is
  # being enabled or disabled.
  #
  # @return [String] the URL to link to
  #
  def partner_url(obj, txt, up)
    link_to(polymorphic_path(obj, "#{obj.class.name.downcase}" => { partner_status: up }), method: :patch) do
      "<i class=\"fa fa-heart\"></i> #{txt}".html_safe
    end
  end
end
