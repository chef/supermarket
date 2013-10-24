module RequestHelpers
  def parsed_response
    @parsed_response ||= if response.body
                           JSON.parse(response.body.strip)
                         else
                           {}
                         end
  end
end
