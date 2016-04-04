module ViewSpecHelpers
  def json_body
    JSON.parse(rendered)
  end

  def xml_body
    Hash.from_xml(rendered)
  end
end
