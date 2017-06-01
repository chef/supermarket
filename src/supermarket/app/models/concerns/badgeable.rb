module Badgeable
  # The list of badges.
  # It would be a phenomenally bad idea to reorder this array's elements.
  # Logic about whether a badge is in the badges_mask is based on the index
  # of the badge text in this array. If you change the order--and therefore the
  # index--the integers stored in the database for a record's badges_mask will
  # no longer match the badges that the record was assigned.
  BADGES = %w[partner].freeze

  module ClassMethods
    #
    # Provides a search method for Badgeable AR::Base models
    #
    def with_badges(badges)
      badges = Array(badges).map(&:to_s)
      search_mask = (badges & BADGES).map { |b| 2**BADGES.index(b) }.inject(0, :+)
      where('badges_mask & ? > 0', search_mask)
    end
  end

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
