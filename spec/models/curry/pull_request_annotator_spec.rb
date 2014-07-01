require 'spec_helper'
require 'vcr_helper'

describe Curry::PullRequestAnnotator, uses_secrets: true do
  describe '#annotate' do
    let(:octokit) do
      Octokit::Client.new(
        access_token: ENV['GITHUB_ACCESS_TOKEN']
      )
    end

    let(:repository) do
      create(:repository, owner: 'gofullstack', name: 'paprika')
    end

    let(:pull_request) do
      Curry::PullRequest.create!(
        number: '1',
        repository: repository
      )
    end

    before do
      VCR.use_cassette('pull_request_annotation_setup', record: :once) do
        octokit.remove_all_labels(
          repository.full_name,
          pull_request.number
        )

        issue_comments = octokit.issue_comments(
          repository.full_name,
          pull_request.number
        )

        issue_comments.each do |comment|
          octokit.delete_comment(
            repository.full_name,
            comment.id
          )
        end
      end
    end

    it 'adds a label to the Pull Request when all commit authors have signed a CLA' do
      VCR.use_cassette('pull_request_annotation_adds_label', record: :once) do
        brett = create(:user)

        brett.accounts.create!(
          provider: 'github',
          username: 'brettchalupa',
          uid: 1,
          oauth_token: 'TOKEN'
        )
        cla = create(:icla)
        create(:icla_signature, user: brett)

        annotator = Curry::PullRequestAnnotator.new(pull_request)

        annotator.annotate

        labels = octokit.labels_for_issue(
          repository.full_name,
          pull_request.number
        )

        label_text = ENV['CURRY_SUCCESS_LABEL']

        expect(labels.map(&:name)).to include(label_text)
      end
    end

    it 'adds a comment to the Pull Request when not all commit authors have signed a CLA' do
      VCR.use_cassette('pull_request_annotation_adds_comment', record: :once) do
        pull_request.commit_authors.create!(login: 'brettchalupa')
        pull_request.commit_authors.create!(
          email: 'brian+bcobb+brettchalupa@gofullstack.com'
        )

        annotator = Curry::PullRequestAnnotator.new(pull_request)

        annotator.annotate

        comments = octokit.issue_comments(
          repository.full_name,
          pull_request.number
        )

        expect(comments.map(&:body)).to_not be_empty
      end
    end

    it 'removes the label before adding a comment' do
      VCR.use_cassette('pull_request_annotation_removes_label', record: :once) do
        octokit.add_labels_to_an_issue(
          repository.full_name,
          pull_request.number,
          [ENV['CURRY_SUCCESS_LABEL']]
        )

        pull_request.commit_authors.create!(login: 'brettchalupa')

        annotator = Curry::PullRequestAnnotator.new(pull_request)

        annotator.annotate

        labels = octokit.labels_for_issue(
          repository.full_name,
          pull_request.number
        )

        label_text = ENV['CURRY_SUCCESS_LABEL']

        expect(labels.map(&:name)).to_not include(label_text)
      end
    end
  end
end
