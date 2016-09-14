require 'spec_helper'

describe MetricResult do
  context 'associations' do
    it { should belong_to(:cookbook_version) }
    it { should belong_to(:quality_metric) }
  end
end
