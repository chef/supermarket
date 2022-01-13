class QualityMetric < ApplicationRecord
  has_many :metric_results, dependent: :destroy

  scope :open, -> { where(admin_only: false) }
  scope :admin_only, -> { where(admin_only: true) }

  validates :name, uniqueness: true

  def self.flip_public
    update_all(admin_only: false) # rubocop:disable Rails/SkipsModelValidations
    all
  end

  def self.flip_admin_only
    update_all(admin_only: true) # rubocop:disable Rails/SkipsModelValidations
    all
  end

  def flip_public
    self.admin_only = false
    save
  end

  def flip_admin_only
    self.admin_only = true
    save
  end

  # This method is kept for the time being to delete all the foodcritic
  # results for a cookbook once worker is run
  def self.foodcritic_metric
    QualityMetric.find_or_create_by!(name: "Foodcritic")
  end

  def self.cookstyle_metric
    QualityMetric.find_or_create_by!(name: "Cookstyle")
  end

  def self.collaborator_num_metric
    QualityMetric.find_or_create_by!(name: "Collaborator Number")
  end

  def self.license_metric
    QualityMetric.find_or_create_by!(name: "License")
  end

  def self.supported_platforms_metric
    QualityMetric.find_or_create_by!(name: "Supported Platforms")
  end

  def self.contributing_file_metric
    QualityMetric.find_or_create_by!(name: "Contributing File")
  end

  def self.testing_file_metric
    QualityMetric.find_or_create_by!(name: "Testing File")
  end

  def self.version_tag_metric
    QualityMetric.find_or_create_by!(name: "Version Tag")
  end

  def self.no_binaries_metric
    QualityMetric.find_or_create_by!(name: "No Binaries")
  end
end
