class CreateMetricResults < ActiveRecord::Migration
  def change
    create_table :metric_results do |t|
      t.references :cookbook_version
      t.references :quality_metric
      t.boolean :failure
      t.string :feedback
      t.timestamps null: false
    end
  end
end
