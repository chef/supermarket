require 'spec_helper'
require 'vcr_helper'

describe Curry::ImportUnknownPullRequestCommitters do
  around(:each) do |example|
    VCR.use_cassette('import_unknown_pull_request_committers', record: :once) do
      example.run
    end
  end

  it 'creates records for the unknown committers of a pull request' do
    # NOTE: This is a repository created to be in _this_ state
    repository = create(:repository, owner: 'cramerdev', name: 'paprika')
    pull_request = create(:pull_request, repository: repository)
    importer = Curry::ImportUnknownPullRequestCommitters.new(pull_request)

    expect do
      importer.import
    end.to change(pull_request.reload.unknown_committers, :count).by(2)
  end

  it 'does not duplicate existing unknown committers' do
    repository = create(:repository, owner: 'cramerdev', name: 'paprika')
    pull_request = create(:pull_request, repository: repository)
    importer = Curry::ImportUnknownPullRequestCommitters.new(pull_request)

    expect do
      2.times { importer.import }
    end.to change(pull_request.reload.unknown_committers, :count).by(2)
  end

end
