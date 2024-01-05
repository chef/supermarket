module FeatureFlagHelper
  def air_gapped?
    ENV["AIR_GAPPED"] == "true"
  end

  def gtag_enabled?
    ENV["ENABLE_GTAG"] == "true"
  end

  def onetrust_enabled?
    ENV["ENABLE_ONETRUST"] == "true"
  end
end
