class QualityMetric < ActiveRecord::Base
  has_many :metric_results

  scope :open, -> { where(admin_only: false) }
  scope :admin_only, -> { where(admin_only: true) }

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

  def self.license_metric
    QualityMetric.find_by(name: 'License')
  end

  def self.supported_platforms_metric
    QualityMetric.find_by(name: 'Supported Platforms')
  end
end
