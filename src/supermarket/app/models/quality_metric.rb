class QualityMetric < ActiveRecord::Base
  has_many :metric_results

  validates :name, uniqueness: true

  def self.foodcritic_metric
    QualityMetric.where(name: 'Foodcritic').first
  end

  def self.collaborator_num_metric
    QualityMetric.where(name: 'Collaborator Number').first
  end
end
