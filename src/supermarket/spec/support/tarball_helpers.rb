require 'and_feathers'
require 'and_feathers/gzipped_tarball'

module TarballHelpers
  #
  # Builds and returns a gzipped tarball Tempfile which contains a directory
  # named and a minimal metadata.json file inside that directory.
  #
  # @example
  #
  #   tarball = build_cookbook_tarball do |base|
  #     base.file('README.md') { 'A readme!' }
  #     base.file('recipes/default.rb') { '# A recipe!' }
  #   end
  #
  # @yieldparam [AndFeathers::Archive]
  #
  # @return [Tempfile]
  #
  def build_cookbook_tarball(name = 'mycookbook', &block)
    Tempfile.new('tarball-fixture', 'tmp').tap do |file|
      io = AndFeathers.build(name) do |base|
        base.file('metadata.json') do
          JSON.dump(name: name, description: 'neat')
        end

        yield(base)
      end.to_io(AndFeathers::GzippedTarball)

      file.write(io.read)
      file.rewind
    end
  end
end
