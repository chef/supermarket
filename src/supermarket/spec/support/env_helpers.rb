module EnvHelpers
  #
  # Given a hash of ENV variables and values, yield a block where that ENV is a
  # reality, and reset ENV after the block is called. Decidedly not threadsafe.
  #
  # @example
  #   with_env('DEBUG' => '1') { ENV['DEBUG'] } #=> '1'
  #
  # @param temporary_env [Hash] the desired ENV variables
  #
  def with_env(temporary_env = {}, &block)
    existing_env = temporary_env.map { |k, _| [k, ENV[k]] }

    temporary_env.each { |k, v| ENV[k] = v }

    yield
  ensure
    existing_env.each { |k, v| ENV[k] = v }
  end
end
