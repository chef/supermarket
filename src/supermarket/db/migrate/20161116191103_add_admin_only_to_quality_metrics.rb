class AddAdminOnlyToQualityMetrics < ActiveRecord::Migration
  def change
    add_column :quality_metrics, :admin_only, :boolean
  end
end
