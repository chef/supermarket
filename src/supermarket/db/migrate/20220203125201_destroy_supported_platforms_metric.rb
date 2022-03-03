class DestroySupportedPlatformsMetric < ActiveRecord::Migration[6.1]
  def change
    if (supported_platforms_metric = QualityMetric.where(name: "Supported Platforms")).exists?
      supported_platforms_metric.destroy_all
    end
  end
end
