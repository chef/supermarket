class DestroyPublishMetrics < ActiveRecord::Migration[6.1]
  def change
    if (publish_metrics = QualityMetric.where(name: "Publish")).exists?
      publish_metrics.destroy_all
    end
  end
end
