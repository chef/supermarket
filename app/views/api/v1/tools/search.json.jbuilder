json.start @start
json.total @total
json.items @results do |tool|
  json.tool_name tool.name
  json.tool_type tool.type
  json.tool_source_url tool.source_url
  json.tool_description tool.description
  json.tool_owner tool.maintainer
  json.tool api_v1_tool_url(tool.slug)
end
