class AddUniqueIndexToQualityMetricsOnName < ActiveRecord::Migration[5.1]
  def change
    add_index :quality_metrics, :name, unique: true
  end
end
