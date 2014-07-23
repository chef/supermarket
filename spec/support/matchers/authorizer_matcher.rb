RSpec::Matchers.define :permit_authorization do |action|
  match do |authorizer|
    authorizer.public_send("#{action}?")
  end

  failure_message do |authorizer|
    "#{authorizer.class} does not permit #{action} on #{authorizer.record} for #{authorizer.user.inspect}!"
  end

  failure_message_when_negated do |authorizer|
    "#{authorizer.class} does not forbid #{action} on #{authorizer.record} for #{authorizer.user.inspect}!"
  end
end
