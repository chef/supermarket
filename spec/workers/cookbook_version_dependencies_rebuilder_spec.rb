require 'and_feathers'
require 'and_feathers/gzipped_tarball'
require 'chef/version_constraint'
require 'chef/exceptions'
require 'spec_helper'

describe CookbookVersionDependenciesRebuilder do
  def tarball_with_dependencies(dependencies)
    Tempfile.new('archive', 'tmp').tap do |file|
      io = AndFeathers.build('archive') do |base|
        base.file('metadata.json') { JSON.dump(dependencies: dependencies) }
      end.to_io(AndFeathers::GzippedTarball)

      file.write(io.read)
      file.rewind
    end
  end

  it 'updates dependencies with incorrectly-imported constraints' do
    cookbook_version = create(:cookbook_version)

    dependencies = {
      apt: '~> 1.0',
      java: '>= 1.0.1',
      node: '0.10.1'
    }

    dependencies.each do |name, version_constraint|
      cookbook_version.cookbook_dependencies.create!(
        name: name,
        version_constraint: Chef::VersionConstraint.new(version_constraint).to_s
      )
    end

    original_dependencies = cookbook_version.cookbook_dependencies.to_a

    CookbookVersionDependenciesRebuilder.new(
      tarball: tarball_with_dependencies(dependencies)
    ).perform(cookbook_version.id)

    new_dependencies = cookbook_version.reload.cookbook_dependencies.to_a

    expect(original_dependencies.map(&:version_constraint)).
      to match_array(['~> 1.0.0', '= 0.10.1', '>= 1.0.1'])
    expect(new_dependencies.map(&:version_constraint)).
      to match_array(['~> 1.0', '0.10.1', '>= 1.0.1'])
  end

  it 'creates a VerifiedCookbookVersion to track progress' do
    cookbook_version = create(:cookbook_version)

    verified_versions = VerifiedCookbookVersion.where(
      cookbook_version_id: cookbook_version.id
    )

    expect do
      CookbookVersionDependenciesRebuilder.new(
        tarball: tarball_with_dependencies({})
      ).perform(cookbook_version.id)
    end.to change(verified_versions, :count).from(0).to(1)
  end
end
