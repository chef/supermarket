module FeatureFlagHelper

  def air_gapped?
    ENV['air_gapped'] == 'true'
  end
end
