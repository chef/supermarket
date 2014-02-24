module ApiViewSpecHelpers
  def json_body
    JSON.parse(rendered)
  end
end
