RSpec::Matchers.define :permit do |action|
  match do |authorizer|
    authorizer.public_send("#{action}?")
  end

  failure_message_for_should do |authorizer|
    "#{authorizer.class} does not permit #{action} on #{authorizer.record} for #{authorizer.user.inspect}!"
  end

  failure_message_for_should_not do |authorizer|
    "#{authorizer.class} does not forbid #{action} on #{authorizer.record} for #{authorizer.user.inspect}!"
  end
end
