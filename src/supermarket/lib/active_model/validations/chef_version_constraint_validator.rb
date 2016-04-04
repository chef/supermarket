require 'active_model'
require 'chef/version_constraint'
require 'chef/exceptions'

module ActiveModel
  module Validations
    #
    # Validates that strings are formatted as Chef version constraints.
    #
    class ChefVersionConstraintValidator < ActiveModel::EachValidator
      #
      # Create a new validator. Called implicitly when
      # a +chef_version_constraint+ validation is added to an attribute.
      #
      # @param options [Hash] validation options
      # @option options [String] :message
      #   ('is not a valid Chef version constraint') a custom validation message
      #
      def initialize(options)
        options.fetch(:message) do
          options.store(:message, 'is not a valid Chef version constraint')
        end

        super(options)
      end

      #
      # Add an error to +attribute+ of +record+ if the given +value+ is not
      # a valid Chef version constraint
      #
      # @param record [ActiveModel::Model]
      # @param attribute [Symbol]
      # @param value
      #
      def validate_each(record, attribute, value)
        Chef::VersionConstraint.new(value)
      rescue Chef::Exceptions::InvalidVersionConstraint, Chef::Exceptions::InvalidCookbookVersion => e
        msg = "#{options.fetch(:message)}. #{e.class}: #{e.message}"
        record.errors.add(attribute, msg, value: value)
      end
    end
  end
end
