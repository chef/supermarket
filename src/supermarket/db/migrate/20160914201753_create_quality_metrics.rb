class CreateQualityMetrics < ActiveRecord::Migration[4.2]
  def change
    create_table :quality_metrics do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
