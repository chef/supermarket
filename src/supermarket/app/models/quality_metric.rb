class QualityMetric < ActiveRecord::Base
  has_many :metric_results

  scope :open, -> { where(admin_only: false) }
  scope :admin_only, -> { where(admin_only: true) }

  validates :name, uniqueness: true

  def self.foodcritic_metric
    QualityMetric.where(name: 'Foodcritic').first_or_create!
  end

  def self.collaborator_num_metric
    QualityMetric.where(name: 'Collaborator Number').first_or_create!
  end

  def self.publish_metric
    QualityMetric.where(name: 'Publish').first_or_create!(admin_only: true)
  end

  def self.license_metric
    QualityMetric.where(name: 'License').first_or_create!(admin_only: true)
  end

  def self.supported_platforms_metric
    QualityMetric.where(name: 'Supported Platforms').first_or_create!(admin_only: true)
  end

  def self.contributor_file_metric
    QualityMetric.find_by(name: 'Contributor File')
  end
end
