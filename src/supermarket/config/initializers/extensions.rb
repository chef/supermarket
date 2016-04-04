require 'supermarket/pundit_policy_class'

ActiveRecord::Base.send(:extend, Supermarket::PunditPolicyClass)
