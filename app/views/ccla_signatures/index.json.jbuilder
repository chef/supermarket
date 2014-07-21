json.array! @ccla_signatures do |signature|
  json.id signature.id
  json.organization_id signature.organization_id
  json.company signature.company
  json.signed_at signature.signed_at.to_s(:longish)
end
