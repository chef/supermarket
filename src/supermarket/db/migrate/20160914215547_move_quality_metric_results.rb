class MoveQualityMetricResults < ActiveRecord::Migration
  def change
    foodcritic_qm = QualityMetric.create!(name: 'Foodcritic')
    collab_num_qm = QualityMetric.create!(name: 'Collaborator Number')

    CookbookVersion.where("foodcritic_failure IS NOT NULL or collaborator_failure IS NOT NULL").each do |cookbook_version|
      if !cookbook_version.foodcritic_failure.nil?
        MetricResult.create!(
          cookbook_version_id: cookbook_version.id,
          quality_metric_id:   foodcritic_qm.id,
          failure:             cookbook_version.foodcritic_failure,
          feedback:            cookbook_version.foodcritic_feedback
        )
      end

      if !cookbook_version.collaborator_failure.nil?
        MetricResult.create!(
          cookbook_version_id: cookbook_version.id,
          quality_metric_id:   collab_num_qm.id,
          failure:             cookbook_version.collaborator_failure,
          feedback:            cookbook_version.collaborator_feedback
        )
      end
    end
  end
end
