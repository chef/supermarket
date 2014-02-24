module ApiSpecHelpers
  def json_body
    JSON.parse(response.body)
  end
end
