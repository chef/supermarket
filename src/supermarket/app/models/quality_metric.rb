class QualityMetric < ActiveRecord::Base
  has_many :metric_results

  validates :name, uniqueness: true

  def self.foodcritic_metric
    QualityMetric.find_by(name: 'Foodcritic')
  end

  def self.collaborator_num_metric
    QualityMetric.find_by(name: 'Collaborator Number')
  end

  def self.publish_metric
    QualityMetric.find_by(name: 'Publish')
  end
end
