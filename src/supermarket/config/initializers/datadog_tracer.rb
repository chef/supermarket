# Disable/Enable and configure the datadog application tracer
# crf. http://www.rubydoc.info/gems/ddtrace/#Ruby_on_Rails

if ENV['DATADOG_TRACER_ENABLED'] && ENV['DATADOG_TRACER_ENABLED'] == 'true'
  require 'ddtrace'
  Rails.configuration.datadog_trace =
    {
      auto_instrument: true,
      auto_instrument_redis: true,
      default_service: ENV['DATADOG_APP_NAME'] || 'rails_app',
      env: ENV['DATADOG_ENVIRONMENT'] || nil
    }
end
