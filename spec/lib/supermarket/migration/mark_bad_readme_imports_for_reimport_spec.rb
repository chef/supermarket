require 'spec_helper'

describe Supermarket::Migration::MarkBadReadmeImportsForReimport do
  it 'resets the state of attributes set by metadata' do
    cookbook_version = create(
      :cookbook_version,
      dependencies_imported: true,
      readme: 'some junk ctime=12345678 some other junk'
    )

    cookbook_version.supported_platforms.create!(name: 'ubuntu')
    cookbook_version.cookbook_dependencies.create!(name: 'apt')

    Supermarket::Migration::MarkBadReadmeImportsForReimport.call

    expect(cookbook_version.reload.dependencies_imported).to eql(false)
    expect(cookbook_version.reload.supported_platforms).to be_empty
    expect(cookbook_version.reload.cookbook_dependencies).to be_empty
  end

  it 'does not affect cookbook versions which do not appear to have bad READMEs' do
    cookbook_version = create(
      :cookbook_version,
      dependencies_imported: true,
      readme: 'some junk and some other junk'
    )

    cookbook_version.supported_platforms.create!(name: 'ubuntu')
    cookbook_version.cookbook_dependencies.create!(name: 'apt')

    Supermarket::Migration::MarkBadReadmeImportsForReimport.call

    expect(cookbook_version.reload.dependencies_imported).to eql(true)
    expect(cookbook_version.reload.supported_platforms).to_not be_empty
    expect(cookbook_version.reload.cookbook_dependencies).to_not be_empty
  end
end
