class AddNotNullConstraintToMetricResults < ActiveRecord::Migration
  def change
    MetricResult.where(quality_metric_id: nil).delete_all
    change_column_null(:metric_results, :quality_metric_id, false)
  end
end
