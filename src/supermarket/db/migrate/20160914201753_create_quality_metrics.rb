class CreateQualityMetrics < ActiveRecord::Migration
  def change
    create_table :quality_metrics do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
