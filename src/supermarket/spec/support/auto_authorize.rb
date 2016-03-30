#
# Stubs out an action for a given model.
# Useful in controller specs where we don't care about the
# business logic for who is authorized but merely what happens
# when they are.
#
# @example
#   auto_authorize!(model, 'action')
#
# @param [ActiveRecord::Base]
# @param [String]
#
def auto_authorize!(model, action)
  allow_any_instance_of(model.policy_class.constantize)
    .to receive((action + '?').to_sym) { true }
end
