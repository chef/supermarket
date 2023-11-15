module FeatureFlagHelper
  def air_gapped?
    ENV["AIR_GAPPED"] == "true"
  end
end
