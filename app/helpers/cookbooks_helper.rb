module CookbooksHelper
  #
  # Return a title for cookbook feeds based on the parameters
  # that are currently set.
  #
  # @example
  #   <%= feed_title %>
  #
  # @return [String] a title based on the current paramters or All
  #
  def feed_title
    (params.fetch(:category, nil) || params.fetch(:order, nil) || 'All').titleize
  end
end
