require 'spec_helper'

describe QualityMetric do
  it { should have_many(:metric_results) }
end
