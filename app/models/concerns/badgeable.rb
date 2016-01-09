module Badgeable
  # The list of badges.
  BADGES = %w(partner).freeze

  #
  # Set the badges on the parent model.
  #
  # @example
  #   cookbook.badges = [:partner] #=> 2
  #
  # @param [Array<Symbol, String>] badges
  #
  # @return [Integer]
  #
  def badges=(badges)
    badges = Array(badges).map(&:to_s)
    self.badges_mask = (badges & BADGES).map { |b| 2**BADGES.index(b) }.inject(0, :+)
  end

  #
  # The list of badges for the parent model.
  #
  # @example
  #   cookbook.badges #=> ['partner']
  #
  # @return [Array<String>]
  #
  def badges
    BADGES.reject do |b|
      (badges_mask.to_i & 2**BADGES.index(b)).zero?
    end
  end

  #
  # Boolean method to determine if the current cookbook is one of a particular
  # badge.
  #
  # @example
  #   cookbook.is?(:partner, :delicious)
  #
  # @param [Array<String, Symbol>] list
  #
  # @return [Boolean]
  #   true if the parent model is any of the given badges, false otherwise
  #
  def is?(*list)
    !(list.map(&:to_s) & badges).empty?
  end

  #
  # Boolean method to determine if the current cookbook is all of the particular
  # badges.
  #
  # @example
  #   cookbook.all?(:partner, :delicious)
  #
  # @param [Array<String, Symbol>] list
  #
  # @return [Boolean]
  #   true if the parent model has all of the given badges, false otherwise
  #
  def all?(*list)
    (list.map(&:to_s) & badges).size == list.size
  end
end
