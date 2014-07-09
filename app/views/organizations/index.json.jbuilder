json.array! @ccla_signatures do |signature|
  json.id signature.organization_id
  json.name signature.company
  json.signed_at signature.signed_at.to_s(:long)
end
