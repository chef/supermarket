module FeatureFlagHelper
  def air_gapped?
    ENV["AIR_GAPPED"] == "true"
  end

  def gtag_enabled?
    ENV["ENABLE_GTAG"] == "true"
  end

  def gtm_enabled?
    ENV["ENABLE_GTM"] == "true"
  end

  def onetrust_enabled?
    ENV["ENABLE_ONETRUST"] == "true"
  end
end
