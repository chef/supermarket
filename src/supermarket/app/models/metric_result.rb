class MetricResult < ActiveRecord::Base
  belongs_to :cookbook_version
  belongs_to :quality_metric
end
