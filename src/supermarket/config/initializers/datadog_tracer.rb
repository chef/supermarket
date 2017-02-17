# Disable/Enable and configure the datadog application tracer
# crf. http://www.rubydoc.info/gems/ddtrace/#Ruby_on_Rails
Rails.configuration.datadog_trace =
  if ENV['DATADOG_TRACER_ENABLED']
    {
      auto_instrument: true,
      auto_instrument_redis: true,
      default_service: ENV['DATADOG_APP_NAME'] || 'rails_app'
    }
  else
    {
      enabled: false,
      auto_instrument: false,
      auto_instrument_redis: false
    }
  end
