FactoryGirl.define do
  factory :metric_result, class: 'MetricResult' do
    association :cookbook_version
    association :quality_metric
    failure true
    feedback 'it failed'
  end
end
