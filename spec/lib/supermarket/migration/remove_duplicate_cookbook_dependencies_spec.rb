require 'spec_helper'

describe Supermarket::Migration::RemoveDuplicateCookbookDependencies do
  it 'deletes duplicate cookbook dependencies' do
    cookbook_version = create(:cookbook).cookbook_versions.first

    2.times do
      cookbook_version.cookbook_dependencies.create(
        name: 'test',
        version_constraint: '>= 0.0.0'
      )
    end

    Supermarket::Migration::RemoveDuplicateCookbookDependencies.call

    expect(cookbook_version.cookbook_dependencies.count).to eql(1)
  end

  it 'does not affect cookbook versions without duplicate dependencies' do
    cookbook_version = create(:cookbook).cookbook_versions.first
    cookbook_version.cookbook_dependencies.create(
      name: 'test',
      version_constraint: '>= 0.0.0'
    )

    Supermarket::Migration::RemoveDuplicateCookbookDependencies.call

    expect(cookbook_version.cookbook_dependencies.count).to eql(1)
  end
end
