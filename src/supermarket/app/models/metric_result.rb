class MetricResult < ActiveRecord::Base
  belongs_to :cookbook_version
  belongs_to :quality_metric

  scope :open, -> { joins(:quality_metric).merge(QualityMetric.open) }
  scope :admin_only, -> { joins(:quality_metric).merge(QualityMetric.admin_only) }

  delegate :name, to: :quality_metric
  delegate :admin_only?, to: :quality_metric
end
