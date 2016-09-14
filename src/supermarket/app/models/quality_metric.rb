class QualityMetric < ActiveRecord::Base
  has_many :metric_results
end
