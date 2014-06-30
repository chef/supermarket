require 'spec_helper'
require 'vcr_helper'

describe Curry::ImportUnknownPullRequestCommitAuthors do
  around(:each) do |example|
    VCR.use_cassette('import_unknown_pull_request_commit_authors', record: :once) do
      example.run
    end
  end

  it 'creates records for the unknown commit authors of a pull request' do
    # NOTE: This is a repository created to be in _this_ state
    repository = create(:repository, owner: 'gofullstack', name: 'paprika')
    pull_request = create(:pull_request, repository: repository)
    importer = Curry::ImportUnknownPullRequestCommitAuthors.new(pull_request)

    expect do
      importer.import
    end.to change(pull_request.reload.unknown_commit_authors, :count).by(2)
  end

  it 'does not duplicate existing unknown commit authors' do
    repository = create(:repository, owner: 'gofullstack', name: 'paprika')
    pull_request = create(:pull_request, repository: repository)
    importer = Curry::ImportUnknownPullRequestCommitAuthors.new(pull_request)

    expect do
      2.times { importer.import }
    end.to change(pull_request.reload.unknown_commit_authors, :count).by(2)
  end

  it 'does not import known commit authors' do
    # NOTE: there is implicit state at work here. The
    # import_unknown_pull_request_commit_authors VCR cassette contains a
    # response for a Pull Request with two commit authors. This spec creates an
    # account in the test database for one of those users. As such, the import
    # should only create one commit author record
    repository = create(:repository, owner: 'gofullstack', name: 'paprika')
    pull_request = create(:pull_request, repository: repository)
    importer = Curry::ImportUnknownPullRequestCommitAuthors.new(pull_request)

    user = create(:user)
    account = create(
      :account,
      user: user,
      username: 'brettchalupa',
      provider: 'github'
    )
    signature = create(:icla_signature, user: user)

    expect do
      importer.import
    end.to change(pull_request.reload.commit_authors, :count).by(1)
  end
end
