class AddAdminOnlyToQualityMetrics < ActiveRecord::Migration[4.2]
  def change
    add_column :quality_metrics, :admin_only, :boolean, default: false, null: false
  end
end
