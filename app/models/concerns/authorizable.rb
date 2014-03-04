module Authorizable
  # The list of roles.
  ROLES = %w[admin].freeze

  #
  # Set the roles on the parent model.
  #
  # @example
  #   user.roles = [:employee] #=> 2
  #
  # @param [Array<Symbol, String>] roles
  #
  # @return [Integer]
  #
  def roles=(roles)
    roles = Array(roles).map(&:to_s)
    self.roles_mask = (roles & ROLES).map { |r| 2**ROLES.index(r) }.inject(0, :+)
  end

  #
  # The list of roles for the parent model.
  #
  # @example
  #   user.roles #=> ['employee']
  #
  # @return [Array<String>]
  #
  def roles
    ROLES.reject do |r|
      (roles_mask.to_i & 2**ROLES.index(r)).zero?
    end
  end

  #
  # Boolean method to determine if the current user is one of a particular
  # role.
  #
  # @example
  #   user.is?(:admin, :employee)
  #
  # @param [Array<String, Symbol>] list
  #
  # @return [Boolean]
  #   true if the parent model is any of the given roles, false otherwise
  #
  def is?(*list)
    !(list.map(&:to_s) & roles).empty?
  end

  #
  # Boolean method to determine if the current user is all of the particular
  # roles.
  #
  # @example
  #   user.all?(:admin, :employee)
  #
  # @param [Array<String, Symbol>] list
  #
  # @return [Boolean]
  #   true if the parent model has all of the given roles, false otherwise
  #
  def all?(*list)
    (list.map(&:to_s) & roles).size == list.size
  end
end
